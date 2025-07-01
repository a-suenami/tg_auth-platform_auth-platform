# typed: false
# frozen_string_literal: true

module UserStripe
  class StripeWebhookHandlerService
    def initialize(event)
      @event = event
      @event_type = event.type
      @event_data = event.data.object
    end

    def process
      case @event_type
      when 'invoice.payment_succeeded'
        handle_invoice_payment_succeeded
      when 'invoice.payment_failed'
        handle_invoice_payment_failed
      when 'customer.subscription.created'
        handle_customer_subscription_created
      when 'customer.subscription.updated'
        handle_customer_subscription_updated
      when 'customer.subscription.deleted'
        handle_customer_subscription_deleted
      when 'payment_intent.succeeded'
        handle_payment_intent_succeeded
      when 'payment_intent.payment_failed'
        handle_payment_intent_payment_failed
      when 'setup_intent.succeeded'
        handle_setup_intent_succeeded
      when 'setup_intent.setup_failed'
        handle_setup_intent_setup_failed
      else
        Rails.logger.info "Unhandled Stripe webhook event: #{@event_type}"
      end
    end

    private

    def handle_invoice_payment_succeeded
      Rails.logger.info "Processing invoice.payment_succeeded: #{@event_data.id}"

      # 関連するsubscriptionを取得
      subscription = StripeRecord::Subscription.find_by(remote_id: @event_data.subscription)
      return unless subscription

      # UserContractを更新
      user_contract = subscription.user_contract
      return unless user_contract

      # メンバーシップの有効期限を延長
      extend_membership_period(user_contract, @event_data)

      # TODO: 必要に応じてメール通知
    end

    def handle_invoice_payment_failed
      Rails.logger.info "Processing invoice.payment_failed: #{@event_data.id}"

      # 関連するsubscriptionを取得
      subscription = StripeRecord::Subscription.find_by(remote_id: @event_data.subscription)
      return unless subscription

      # UserContractのステータスを更新
      user_contract = subscription.user_contract
      return unless user_contract

      # 決済失敗の処理
      handle_payment_failure(user_contract, @event_data)
    end

    def handle_customer_subscription_created
      Rails.logger.info "Processing customer.subscription.created: #{@event_data.id}"

      # StripeRecord::Subscriptionの作成/更新
      update_stripe_subscription(@event_data)
    end

    def handle_customer_subscription_updated
      Rails.logger.info "Processing customer.subscription.updated: #{@event_data.id}"

      # StripeRecord::Subscriptionの更新
      update_stripe_subscription(@event_data)
    end

    def handle_customer_subscription_deleted
      Rails.logger.info "Processing customer.subscription.deleted: #{@event_data.id}"

      # StripeRecord::Subscriptionのステータス更新
      subscription = StripeRecord::Subscription.find_by(remote_id: @event_data.id)
      return unless subscription

      subscription.update!(status: 'canceled')

      # 関連するUserContractのキャンセル処理
      user_contract = subscription.user_contract
      return unless user_contract

      cancel_user_contract(user_contract)
    end

    def handle_payment_intent_succeeded
      Rails.logger.info "Processing payment_intent.succeeded: #{@event_data.id}"

      # StripeRecord::PaymentIntentの更新
      payment_intent = StripeRecord::PaymentIntent.find_by(remote_id: @event_data.id)
      return unless payment_intent

      payment_intent.update!(
        status: @event_data.status,
        # 他の必要な属性を更新
      )
    end

    def handle_payment_intent_payment_failed
      Rails.logger.info "Processing payment_intent.payment_failed: #{@event_data.id}"

      # StripeRecord::PaymentIntentの更新
      payment_intent = StripeRecord::PaymentIntent.find_by(remote_id: @event_data.id)
      return unless payment_intent

      payment_intent.update!(
        status: @event_data.status,
        # 他の必要な属性を更新
      )
    end

    def handle_setup_intent_succeeded
      Rails.logger.info "Processing setup_intent.succeeded: #{@event_data.id}"

      # StripeRecord::SetupIntentの更新
      setup_intent = StripeRecord::SetupIntent.find_by(remote_id: @event_data.id)
      return unless setup_intent

      setup_intent.update!(
        status: @event_data.status,
        # 他の必要な属性を更新
      )

      # PaymentMethodの作成
      setup_intent.create_card_payment_method
    end

    def handle_setup_intent_setup_failed
      Rails.logger.info "Processing setup_intent.setup_failed: #{@event_data.id}"

      # StripeRecord::SetupIntentの更新
      setup_intent = StripeRecord::SetupIntent.find_by(remote_id: @event_data.id)
      return unless setup_intent

      setup_intent.update!(
        status: @event_data.status,
        # 他の必要な属性を更新
      )
    end


    def update_stripe_subscription(stripe_subscription_data)
      subscription = StripeRecord::Subscription.find_or_initialize_by(remote_id: stripe_subscription_data.id)

      subscription.assign_attributes(
        status: stripe_subscription_data.status,
        # 他の必要な属性を設定
      )

      subscription.save!
    end

    def extend_membership_period(user_contract, invoice_data)
      # メンバーシップの有効期限を延長する処理
      # TODO: 実装
    end

    def handle_payment_failure(user_contract, invoice_data)
      # 決済失敗の処理
      # TODO: 実装
    end

    def cancel_user_contract(user_contract)
      # UserContractのキャンセル処理
      # TODO: 実装
    end
  end
end
