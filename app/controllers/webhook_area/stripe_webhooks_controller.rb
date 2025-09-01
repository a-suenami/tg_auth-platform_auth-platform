# typed: false
# frozen_string_literal: true

module WebhookArea
  class StripeWebhooksController < WebhookArea::ApplicationController
    before_action :verify_stripe_signature

    def create
      event = parse_stripe_event

      # サービスクラスを使用してイベントを処理
      UserStripe::StripeWebhookHandlerService.new(event).process

      head :ok
    rescue => e
      Sentry.capture_exception(e, extra: {
        event: @event,
      },)
      head :unprocessable_entity
    end

    private

    def verify_stripe_signature
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']

      # テナントのwebhook_secretを取得
      tenant_stripe_account = Tenant.current&.tenant_stripe_account
      endpoint_secret = tenant_stripe_account&.webhook_secret

      unless endpoint_secret
        head :bad_request
        return
      end

      begin
        event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
      rescue JSON::ParserError, Stripe::SignatureVerificationError
        head :bad_request
        return
      end

      @stripe_event = event
    end

    def parse_stripe_event
      @stripe_event
    end

    # Webhook event handlers
    def handle_invoice_payment_succeeded(event)
      Rails.logger.info "Processing invoice.payment_succeeded: #{event.data.object.id}"
      # TODO: 実装
      # - 関連するContractのステータスを更新
      # - メンバーシップの有効期限を延長
      # - 必要に応じてメール通知
    end

    def handle_invoice_payment_failed(event)
      Rails.logger.info "Processing invoice.payment_failed: #{event.data.object.id}"
      # TODO: 実装
      # - 関連するContractのステータスを更新
      # - 決済失敗の通知
      # - 再試行の設定
    end

    def handle_customer_subscription_created(event)
      Rails.logger.info "Processing customer.subscription.created: #{event.data.object.id}"
      # TODO: 実装
      # - StripeRecord::Subscriptionの作成/更新
      # - 関連するContractの初期化
    end

    def handle_customer_subscription_updated(event)
      Rails.logger.info "Processing customer.subscription.updated: #{event.data.object.id}"
      # TODO: 実装
      # - StripeRecord::Subscriptionの更新
      # - 関連するContractの更新
    end

    def handle_customer_subscription_deleted(event)
      Rails.logger.info "Processing customer.subscription.deleted: #{event.data.object.id}"
      # TODO: 実装
      # - StripeRecord::Subscriptionのステータス更新
      # - 関連するContractのキャンセル処理
    end

    def handle_payment_intent_succeeded(event)
      Rails.logger.info "Processing payment_intent.succeeded: #{event.data.object.id}"
      # TODO: 実装
      # - StripeRecord::PaymentIntentの更新
      # - 関連する決済処理の完了
    end

    def handle_payment_intent_payment_failed(event)
      Rails.logger.info "Processing payment_intent.payment_failed: #{event.data.object.id}"
      # TODO: 実装
      # - StripeRecord::PaymentIntentの更新
      # - 決済失敗の処理
    end

    def handle_setup_intent_succeeded(event)
      Rails.logger.info "Processing setup_intent.succeeded: #{event.data.object.id}"
      # TODO: 実装
      # - StripeRecord::SetupIntentの更新
      # - PaymentMethodの作成
    end

    def handle_setup_intent_setup_failed(event)
      Rails.logger.info "Processing setup_intent.setup_failed: #{event.data.object.id}"
      # TODO: 実装
      # - StripeRecord::SetupIntentの更新
      # - セットアップ失敗の処理
    end
  end
end
