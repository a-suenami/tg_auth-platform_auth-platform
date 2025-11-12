# typed: false
# frozen_string_literal: true

module WebhookArea
  class KomojuWebhooksController < WebhookArea::ApplicationController
    skip_before_action :set_tenant
    before_action :verify_komoju_signature

    def create
      event_type = @webhook_payload['type']
      event_data = @webhook_payload['data']

      case event_type
      when 'payment.authorized'
        handle_payment_authorized(event_data)
      when 'payment.captured'
        handle_payment_captured(event_data)
      when 'payment.expired'
        handle_payment_expired(event_data)
      when 'payment.cancelled'
        handle_payment_cancelled(event_data)
      when 'ping'
        # Komoju sends ping event for webhook testing
        Rails.logger.info "Received Komoju ping event"
      else
        Rails.logger.info "Unhandled Komoju event type: #{event_type}"
      end

      head :ok
    rescue => e
      Sentry.capture_exception(e, extra: {
        event_type: event_type,
        event_data: event_data,
      })
      head :unprocessable_entity
    end

    private

    def verify_komoju_signature
      payload = request.body.read
      signature_header = request.env['HTTP_X_KOMOJU_SIGNATURE']
      webhook_secret = Settings.komoju.webhook_secret

      unless webhook_secret
        Rails.logger.error "Komoju webhook secret not configured"
        head :bad_request
        return
      end

      unless signature_header
        Rails.logger.error "Missing X-Komoju-Signature header"
        head :bad_request
        return
      end

      # Compute SHA-256 HMAC signature
      computed_signature = OpenSSL::HMAC.hexdigest('SHA256', webhook_secret, payload)

      # Secure comparison to prevent timing attacks
      unless ActiveSupport::SecurityUtils.secure_compare(computed_signature, signature_header)
        Rails.logger.error "Invalid Komoju webhook signature"
        head :unauthorized
        return
      end

      # Parse and store payload
      @webhook_payload = JSON.parse(payload)
    rescue JSON::ParserError
      Rails.logger.error "Invalid JSON in Komoju webhook payload"
      head :bad_request
    end

    # Event handlers
    def handle_payment_authorized(data)
      payment_id = data['id']
      Rails.logger.info "Processing payment.authorized: #{payment_id}"

      payment = KomojuRecord::Payment.find_by(remote_id: payment_id)
      return unless payment

      # Set tenant context for multitenancy
      set_tenant_from_payment(payment)

      payment.assign_response(data)
      payment.save!
    end

    def handle_payment_captured(data)
      payment_id = data['id']
      Rails.logger.info "Processing payment.captured: #{payment_id}"

      payment = KomojuRecord::Payment.find_by(remote_id: payment_id)
      return unless payment

      # Set tenant context for multitenancy
      set_tenant_from_payment(payment)

      # Update payment record
      payment.assign_response(data)
      payment.captured_at = Time.zone.now
      payment.save!

      # Get transaction (should exist from service)
      transaction = payment.payment_transaction
      unless transaction
        Rails.logger.error "Transaction not found for payment: #{payment_id}"
        raise "Transaction not found for payment: #{payment_id}"
      end

      # Get contract (should exist from service)
      membership_contract = transaction.membership_contract
      unless membership_contract
        Rails.logger.error "Contract not found for transaction: #{transaction.id}"
        raise "Contract not found for transaction: #{transaction.id}"
      end

      # Calculate membership period from payment captured time
      current_contract_term = membership_contract.current_contract_term
      membership_plan = current_contract_term.membership_plan
      start_at = Time.zone.now
      end_at = membership_plan.calculate_expiry_date(from: start_at)

      # Update contract with expiry date
      membership_contract.update!(status: :active, expired_at: end_at)

      # Update transaction with activation and expiry dates
      transaction.update!(
        status: :active,
        activated_at: start_at,
        expired_at: end_at
      )

      # Update contract term with start and end dates
      current_contract_term.update!(
        start_at: start_at,
        end_at: end_at
      )

      # Activate membership users with expiry dates
      membership_contract.membership_users.update_all(
        status: :active,
        activated_at: start_at,
        expired_at: end_at
      )

      Rails.logger.info "Activated contract: #{membership_contract.id}, transaction: #{transaction.id}, period: #{start_at} to #{end_at}"
    end

    def handle_payment_expired(data)
      payment_id = data['id']
      Rails.logger.info "Processing payment.expired: #{payment_id}"

      payment = KomojuRecord::Payment.find_by(remote_id: payment_id)
      return unless payment

      # Set tenant context for multitenancy
      set_tenant_from_payment(payment)

      payment.assign_response(data)
      payment.expired_at = Time.zone.now
      payment.save!

      # Update payment transaction if exists
      if payment.payment_transaction
        payment.payment_transaction.update!(status: :expired)
        Rails.logger.info "Payment transaction marked as expired: #{payment.payment_transaction.id}"
      end
    end

    def handle_payment_cancelled(data)
      payment_id = data['id']
      Rails.logger.info "Processing payment.cancelled: #{payment_id}"

      payment = KomojuRecord::Payment.find_by(remote_id: payment_id)
      return unless payment

      # Set tenant context for multitenancy
      set_tenant_from_payment(payment)

      payment.assign_response(data)
      payment.save!

      # Update payment transaction if exists
      if payment.payment_transaction
        payment.payment_transaction.update!(status: :canceled)
        Rails.logger.info "Payment transaction marked as canceled: #{payment.payment_transaction.id}"
      end
    end

    def set_tenant_from_payment(payment)
      tenant = Tenant.find(payment.tenant_id)
      RequestStore.store[:current_tenant_domain] = tenant.domain
      RequestStore.store[:current_tenant] = tenant.id
      RequestStore.store[:current_tenant_object] = tenant
    end
  end
end
