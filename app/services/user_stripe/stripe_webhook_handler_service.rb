# typed: false
# frozen_string_literal: true

module UserStripe
  class StripeWebhookHandlerService
    def initialize(event)
      @event = event
    end

    def process
      case @event.type
      when 'payment_intent.succeeded'
        handle_payment_intent_succeeded
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
      when 'setup_intent.succeeded'
        handle_setup_intent_succeeded
      when 'setup_intent.setup_failed'
        handle_setup_intent_setup_failed
      else
        Rails.logger.info "Unhandled webhook event: #{@event.type}"
      end
    end

    private

    def handle_payment_intent_succeeded
      payment_intent = @event.data.object
      Rails.logger.info "Processing payment_intent.succeeded: #{payment_intent.id}"

      # StripeRecord::PaymentIntentを更新
      stripe_record_payment_intent = StripeRecord::PaymentIntent.find_by(remote_id: payment_intent.id)
      return unless stripe_record_payment_intent

      stripe_record_payment_intent.update!(
        status: payment_intent.status,
        metadata: payment_intent.metadata&.to_h,
      )

      # 関連するUserContractを取得（invoiceを通じて）
      user_contract = stripe_record_payment_intent.invoice&.chargeable&.activation_source&.user_contract
      return unless user_contract

      # 契約完了処理
      complete_user_contract(user_contract, payment_intent, stripe_record_payment_intent)
    end

    def complete_user_contract(user_contract, _payment_intent, stripe_record_payment_intent)
      ActiveRecord::Base.transaction do
        # UserContractのステータスをアクティブに変更
        user_contract.update!(
          status: 'active',
        )
        invoice = stripe_record_payment_intent.invoice
        stripe_record_subscription = invoice&.chargeable
        activation_source = stripe_record_subscription&.activation_source
        plan = activation_source.membership_plan
        return unless plan

        # プラン内容に従って有効期限を設定
        if plan.recurrence
          # 定期契約の場合
          user_contract.update!(
            expires_at: calculate_recurring_expiry_date(Time.zone.now, plan),
          )
        else
          # 一回払いの場合
          user_contract.update!(
            expires_at: calculate_recurring_expiry_date(Time.zone.now, plan),
          )
        end
        # 関連するStripeRecordを更新
        update_stripe_records(stripe_record_payment_intent)
        # Memberships::Userのステータスを有効に変更
        update_membership_user(user_contract)
        Rails.logger.info "User contract #{user_contract.id} completed successfully"
      end
    rescue => e
      Rails.logger.error "Failed to complete user contract: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise
    end

    def update_stripe_records(stripe_record_payment_intent)
      # Stripeecord::Subscriptionの更新
      if stripe_record_payment_intent.invoice&.chargeable
        stripe_record_payment_intent.invoice&.chargeable&.update!(
          status: 'active',
        )
      end
      # StripeRecord::Invoiceの更新
      if stripe_record_payment_intent.invoice
        stripe_record_payment_intent.invoice.update!(
          status: 'paid',
        )
      end

      # StripRecord::PaymentIntentの更新
      if stripe_record_payment_intent
        stripe_record_payment_intent.update!(
          status: 'succeeded',
        )
      end
    end

    def calculate_recurring_expiry_date(activated_at, plan)
      case plan.validity_period
      when 'month'
        activated_at + 1.month
      when 'year'
        activated_at + 1.year
      else
        activated_at + 1.month # デフォルト
      end
    end


    def handle_invoice_payment_succeeded
      Rails.logger.info "Processing invoice.payment_succeeded: #{@event.data.object.id}"
      # TODO: 実装
    end

    def handle_invoice_payment_failed
      Rails.logger.info "Processing invoice.payment_failed: #{@event.data.object.id}"
      # TODO: 実装
    end

    def handle_customer_subscription_created
      Rails.logger.info "Processing customer.subscription.created: #{@event.data.object.id}"
      # TODO: 実装
    end

    def handle_customer_subscription_updated
      Rails.logger.info "Processing customer.subscription.updated: #{@event.data.object.id}"
      # TODO: 実装
    end

    def handle_customer_subscription_deleted
      Rails.logger.info "Processing customer.subscription.deleted: #{@event.data.object.id}"
      # TODO: 実装
    end

    def handle_setup_intent_succeeded
      Rails.logger.info "Processing setup_intent.succeeded: #{@event.data.object.id}"
      # TODO: 実装
    end

    def handle_setup_intent_setup_failed
      Rails.logger.info "Processing setup_intent.setup_failed: #{@event.data.object.id}"
      # TODO: 実装
    end

    def update_membership_user(user_contract)
      # TODO: 実装
    end
  end
end
