# typed: false
# frozen_string_literal: true

module UserStripe
  class StripeWebhookHandlerService < UserStripe::BaseService
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

    # TODO: 冪等な処理にする
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

      # 関連するContractを取得（invoiceを通じて）
      contract = stripe_record_payment_intent.invoice&.chargeable&.current_billing_profile&.contract
      return unless contract

      invoice = stripe_record_payment_intent.invoice
      stripe_record_subscription = invoice&.chargeable
      # 関連するStripeRecordを更新
      update_stripe_record_payment_intent(stripe_record_payment_intent)
      # 契約完了処理
      complete_contract(contract, stripe_record_subscription)
    end

    def complete_contract(contract, stripe_record_subscription)
      ActiveRecord::Base.transaction do
        # Contractのステータスをアクティブに変更
        contract.update!(
          status: 'active',
        )

        current_billing_profile = stripe_record_subscription&.current_billing_profile
        plan = current_billing_profile.membership_plan
        return unless plan

        # プラン内容に従って有効期限を設定
        if plan.recurrence
          # 定期契約の場合
          contract.update!(
            expires_at: calculate_recurring_expiry_date(Time.zone.now, plan),
          )
        else
          # 一回払いの場合
          contract.update!(
            expires_at: calculate_recurring_expiry_date(Time.zone.now, plan),
          )
        end

        # Memberships::Userのステータスを有効に変更
        update_membership_user(contract)
        # トライアル履歴を作成
        if stripe_record_subscription.trial_start.present?
          create_trial_history(contract:, stripe_record_subscription:)
        end
        Rails.logger.info "User contract #{contract.id} completed successfully"
      end
    rescue => e
      Rails.logger.error "Failed to complete user contract: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise
    end


    def create_trial_history(contract:, stripe_record_subscription:)
      membership_plan = contract.current_billing_profile.membership_plan
      memberships = membership_plan.memberships
      memberships.each do |membership|
        Memberships::TrialHistory.create!(
          tenant_id: contract.tenant_id,
          user: contract.user,
          membership:,
          membership_plan:,
          stripe_record_subscription:,
          fingerprint: get_card_fingerprint(fetch_default_payment_method_or_default_source_of(contract.user)),
          trial_period_days: membership_plan.trial_period_days,
          trial_start: stripe_record_subscription.trial_start,
          trial_end: stripe_record_subscription.trial_end,
        )
      end
    end

    def update_stripe_record_payment_intent(stripe_record_payment_intent)
      # Stripeecord::Subscriptionの更新
      if stripe_record_payment_intent.invoice&.chargeable
        # TODO: トライアル中の場合はstatusがactiveではなくtrialingになる。
        # payment_intentの成功時にsubscriptionの更新を行なっても良いか要検討(基本ここから失敗することはないと思うが)
        stripe_record_payment_intent.invoice&.chargeable&.update!(
          status: 'active',
        )
      end
      # StripeRecord::SubscriptionItemの更新
      if stripe_record_payment_intent.invoice&.chargeable&.subscription_items
        stripe_record_payment_intent.invoice&.chargeable&.subscription_items&.each do |subscription_item|
          subscription_item.update!(
            current_period_end: 'active',
          )
        end
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

    def update_stripe_record_setup_intent(stripe_record_setup_intent)
      if stripe_record_setup_intent
        stripe_record_setup_intent.update!(
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

      setup_intent = @event.data.object
      stripe_record_setup_intent = StripeRecord::SetupIntent.find_by(remote_id: setup_intent.id)
      return unless stripe_record_setup_intent

      update_stripe_record_setup_intent(stripe_record_setup_intent)
      stripe_record_subscription = stripe_record_setup_intent.subscription
      return unless stripe_record_subscription

      contract = stripe_record_subscription.current_billing_profile.contract
      return unless contract

      complete_contract(contract, stripe_record_subscription)
    end

    def handle_setup_intent_setup_failed
      Rails.logger.info "Processing setup_intent.setup_failed: #{@event.data.object.id}"
      # TODO: 実装
    end

    def update_membership_user(contract)
      membership_plan = contract.current_billing_profile.membership_plan
      memberships = membership_plan.memberships
      memberships.each do |membership|
        membership_user = Memberships::User.find_or_create_by!(
          tenant_id: contract.tenant_id,
          user: contract.user,
          membership:,
        )
        # TODO: トライアルの場合、トライアル期限までに設定
        membership_user.update!(
          status: 'active',
          expires_at: calculate_recurring_expiry_date(Time.zone.now, membership_plan),
        )
      end
    end
  end
end
