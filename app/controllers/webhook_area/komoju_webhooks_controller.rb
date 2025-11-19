# typed: false
# frozen_string_literal: true

module WebhookArea
  class KomojuWebhooksController < WebhookArea::ApplicationController
    before_action :verify_komoju_signature

    def create
      event_type = @webhook_payload['type']
      event_data = @webhook_payload['data']

      case event_type
      when 'payment.authorized'
        Webhook::Komoju::PaymentAuthorizedService.new.execute(event_data: event_data)
      when 'payment.captured'
        Webhook::Komoju::PaymentCapturedService.new.execute(event_data: event_data)
      when 'payment.expired'
        Webhook::Komoju::PaymentExpiredService.new.execute(event_data: event_data)
      when 'payment.cancelled'
        Webhook::Komoju::PaymentCancelledService.new.execute(event_data: event_data)
      when 'ping'
        # Komoju sends ping event for webhook testing
        Rails.logger.info "Received Komoju ping event for tenant: #{Tenant.current.id}"
      else
        Rails.logger.info "Unhandled Komoju event type: #{event_type}"
      end

      head :ok
    rescue => e
      Sentry.capture_exception(e, extra: {
        tenant_id: Tenant.current&.id,
        event_type: event_type,
        event_data: event_data,
      },)
      head :unprocessable_entity
    end

    private

    def verify_komoju_signature
      payload = request.body.read
      signature_header = request.env['HTTP_X_KOMOJU_SIGNATURE']

      # Get tenant-specific webhook secret
      tenant = Tenant.current
      unless tenant&.tenant_komoju_account&.enabled?
        Rails.logger.error "Komoju account not configured or disabled for tenant: #{tenant&.id}"
        head :bad_request
        return
      end

      webhook_secret = tenant.tenant_komoju_account.webhook_secret

      unless signature_header
        Rails.logger.error 'Missing X-Komoju-Signature header'
        head :bad_request
        return
      end

      # Compute SHA-256 HMAC signature
      computed_signature = OpenSSL::HMAC.hexdigest('SHA256', webhook_secret, payload)

      # Secure comparison to prevent timing attacks
      unless ActiveSupport::SecurityUtils.secure_compare(computed_signature, signature_header)
        Rails.logger.error "Invalid Komoju webhook signature for tenant: #{tenant&.id}"
        head :unauthorized
        return
      end

      # Parse and store payload
      @webhook_payload = JSON.parse(payload)
    rescue JSON::ParserError
      Rails.logger.error 'Invalid JSON in Komoju webhook payload'
      head :bad_request
    end

  end
end
