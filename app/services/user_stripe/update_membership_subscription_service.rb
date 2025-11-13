# typed: false

# ==============================================================================
# app/services/user_stripe/cancel_subscription_service.rb
# ==============================================================================
module UserStripe
  class UpdateMembershipSubscriptionService < UserStripe::BaseService

    def initialize(event:)
      @event = event
    end

    def execute
      # subscription契約の自動更新処理
      stripe_record_subscription = StripeRecord::Subscription.find_by(remote_id: @event.data.object.subscription)
      return if stripe_record_subscription.nil?

      contract = stripe_record_subscription.payment_subscription.membership_contract
      return unless contract

      current_term = contract.current_contract_term

      return unless current_term


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
        handle_payment_retry_success(contract, stripe_record_subscription)
        return
      end

      # プラン変更の確認
      handle_subscription_renewal(contract, stripe_record_subscription)
    end

    private

    def handle_subscription_renewal(contract, stripe_record_subscription)
      next_period_end = Time.zone.at(@event&.data&.object&.lines&.data&.[](0)&.period&.end)

      ActiveRecord::Base.transaction do
        contract.update(expired_at: next_period_end)
        # 共通処理: membership_userの更新
        update_membership_user(contract, next_period_end)

        if contract.upcoming_contract_term.present?
          renew_with_plan_change(contract, stripe_record_subscription, next_period_end)
        else
          renew_without_changes(contract, stripe_record_subscription, next_period_end)
        end
      end
    rescue => e
      Sentry.capture_exception(e, extra: {
        contract_id: contract.id,
        stripe_record_subscription_id: stripe_record_subscription.id,
      },)
      raise
    end

    def renew_without_changes(_contract, stripe_record_subscription, next_period_end)
      # stripe_record_subscriptionの更新
      stripe_record_subscription.update!(
        current_period_start: Time.zone.now,
        current_period_end: next_period_end,
        status: 'active',
      )
    end

    def renew_with_plan_change(contract, stripe_record_subscription, next_period_end)
      contract.current_contract_term.update!(
        phase: 'closed',
      )
      contract.upcoming_contract_term.update!(
        status: 'active',
        phase: 'current',
        expires_at: next_period_end,
        activated_at: Time.zone.now,
      )

      # contractの期限更新
      contract.update!(expired_at: next_period_end)

      # stripe_record_subscriptionの更新
      stripe_record_subscription.update!(
        current_period_start: Time.zone.now,
        current_period_end: next_period_end,
        status: 'active',
      )
    end

    def update_membership_user(contract, next_period_end)
      membership_plan = contract.current_contract_term.membership_plan
      # TODO:期限をStripeの次回更新に合わせる
      memberships = membership_plan.memberships
      memberships.each do |membership|
        membership_user = Membership::User.find_or_create_by!(
          tenant_id: contract.tenant_id,
          user: contract.user,
          membership:,
        )
        membership_user.update!(
          status: 'active',
          activated_at: membership_user.activated_at || Time.zone.now,
          expired_at: next_period_end,
        )
      end
    end
  end
end
