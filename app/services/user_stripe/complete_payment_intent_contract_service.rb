# typed: false

module UserStripe
  class CompletePaymentIntentContractService < UserStripe::BaseService
    def initialize(event:)
      @event = event
    end

    def execute
      payment_intent = @event.data.object

      # StripeRecord::PaymentIntentを更新
      stripe_record_payment_intent = StripeRecord::PaymentIntent.find_by(remote_id: payment_intent.id)
      return unless stripe_record_payment_intent

      stripe_record_payment_intent.update!(
        status: payment_intent.status,
        metadata: payment_intent.metadata&.to_h,
      )

      # 関連するContractを取得（invoiceを通じて）
      contract = stripe_record_payment_intent.invoice&.chargeable&.current_billing_profile&.contract
      contract.update!(
        status: 'active',
      )
      return unless contract

      invoice = stripe_record_payment_intent.invoice
      stripe_record_subscription = invoice&.chargeable
      # 関連するStripeRecordを更新
      update_stripe_record_payment_intent(stripe_record_payment_intent)
      # 契約完了処理
      UserStripe::CompleteContractService.new(contract, stripe_record_subscription).execute
    end

    private

    def update_stripe_record_payment_intent(stripe_record_payment_intent)
      # Stripeecord::Subscriptionの更新
      # TODO: トライアル中の場合はstatusがactiveではなくtrialingになる。
      # payment_intentの成功時にsubscriptionの更新を行なっても良いか要検討(基本ここから失敗することはないと思うが)
      stripe_record_payment_intent.invoice&.chargeable&.update!(
        status: 'active',
      )
      # StripeRecord::SubscriptionItemの更新
      stripe_record_payment_intent.invoice&.chargeable&.subscription_items&.each do |subscription_item|
        subscription_item.update!(
          current_period_end: 'active',
        )
      end
      # StripeRecord::Invoiceの更新
      stripe_record_payment_intent.invoice&.update!(
        status: 'paid',
      )

      # StripRecord::PaymentIntentの更新
      stripe_record_payment_intent&.update!(
        status: 'succeeded',
      )
    end


    def calculate_recurring_expiry_date(activated_at, plan)
      case plan.validity_period
      when 'month'
        activated_at + 1.month
      when 'year'
        activated_at + 1.year
      else
        raise Exceptions::Payment::InvalidPlan
      end
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
