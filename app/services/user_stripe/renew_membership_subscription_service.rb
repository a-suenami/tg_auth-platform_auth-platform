# typed: false

# ==============================================================================
# app/services/user_stripe/cancel_subscription_service.rb
# ==============================================================================
module UserStripe
  class RenewMembershipSubscriptionService < UserStripe::BaseService

    def initialize(event:)
      @event = event
    end

    def execute
      # subscription契約の自動更新処理
      stripe_record_subscription = StripeRecord::Subscription.find_by(remote_id: @event.data.object.subscription)
      return if stripe_record_subscription.nil?

      stripe_record_subscription.current_billing_profile.membership_contract

      # 現在のbilling_profileを取得
      current_billing_profile = stripe_record_subscription.current_billing_profile

      return unless current_billing_profile

      contract = current_billing_profile.membership_contract
      return unless contract

      # 自動更新停止済みの場合は処理しない
      if contract.cancel_at_period_end
        # 自動更新を止めているのに決済が走ってしまっている異常自体
        # Sentryに投げる
        Sentry.capture_exception(Exceptions::Payment::InvoicePaidOnCanceledSubscription, extra: {
          contract_id: contract.id,
          stripe_record_subscription_id: stripe_record_subscription.id,
        },)
        return
      end

      # TODO: 失敗時のステータス考慮
      # 決済失敗後の自動リトライで決済された場合の処理
      if contract.status == 'pending'
        handle_payment_retry_success(contract, stripe_record_subscription, current_billing_profile)
        return
      end

      # プラン変更の確認
      handle_subscription_renewal(contract, stripe_record_subscription, current_billing_profile)
    end

    private

    def handle_subscription_renewal(contract, stripe_record_subscription, current_billing_profile)
      upcoming_billing_profile = stripe_record_subscription.upcoming_billing_profile
      next_period_end = Time.zone.at(@event&.data&.object&.lines&.data&.[](0)&.period&.end)

      ActiveRecord::Base.transaction do
        contract.update(expires_at: next_period_end)
        # 共通処理: membership_userの更新
        update_membership_user(contract, next_period_end)

        if upcoming_billing_profile.present?
          renew_with_plan_change(contract, stripe_record_subscription, current_billing_profile, upcoming_billing_profile, next_period_end)
        else
          # プラン変更の場合は、upcoming_billing_profileをcurrentに変更
          renew_without_changes(contract, stripe_record_subscription, current_billing_profile, next_period_end)
        end
      end
    rescue => e
      Sentry.capture_exception(e, extra: {
        contract_id: contract.id,
        stripe_record_subscription_id: stripe_record_subscription.id,
      },)
      raise
    end

    def renew_without_changes(contract, stripe_record_subscription, current_billing_profile, next_period_end)
      # 現在のbilling_profileをpastに変更
      current_billing_profile.update!(
        phase: 'closed',
      )

      # 新しいbilling_profileを作成
      create_new_billing_profile_for_plan_change(current_billing_profile, contract, stripe_record_subscription)

      # stripe_record_subscriptionの更新
      stripe_record_subscription.update!(
        current_period_start: Time.zone.now,
        current_period_end: next_period_end,
        status: 'active',
      )
    end

    def create_new_billing_profile_for_plan_change(current_billing_profile, contract, stripe_record_subscription)
      Memberships::BillingProfile.create!(
        tenant_id: contract.tenant_id,
        user: contract.user,
        membership_plan: current_billing_profile.membership_plan,
        membership_contract: contract,
        chargeable: stripe_record_subscription,
        payment_type: current_billing_profile.payment_type,
        payment_provider: current_billing_profile.payment_provider,
        phase: 'current',
        activated_at: Time.zone.now,
        expires_at: contract.expires_at,
        status: 'active',
        recurrence: current_billing_profile.recurrence,
        revision: current_billing_profile.revision + 1,
      )
    end

    def renew_with_plan_change(contract, stripe_record_subscription, current_billing_profile, upcoming_billing_profile, next_period_end)
      # 現在のbilling_profileをpastに変更
      current_billing_profile.update!(
        phase: 'closed',
      )
      upcoming_billing_profile.update!(
        status: 'active',
        phase: 'current',
        expires_at: next_period_end,
        activated_at: Time.zone.now,
      )

      # contractの期限更新
      contract.update!(expires_at: next_period_end)

      # stripe_record_subscriptionの更新
      stripe_record_subscription.update!(
        current_period_start: Time.zone.now,
        current_period_end: next_period_end,
        status: 'active',
      )
    end

    def update_membership_user(contract, next_period_end)
      membership_plan = contract.current_billing_profile.membership_plan
      # TODO:期限をStripeの次回更新に合わせる
      memberships = membership_plan.memberships
      memberships.each do |membership|
        membership_user = Memberships::User.find_or_create_by!(
          tenant_id: contract.tenant_id,
          user: contract.user,
          membership:,
        )
        membership_user.update!(
          status: 'active',
          expires_at: next_period_end,
        )
      end
    end
  end
end
