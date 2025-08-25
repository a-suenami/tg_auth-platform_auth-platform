# typed: false

# ==============================================================================
# app/services/user_stripe/cancel_subscription_service.rb
# ==============================================================================
module UserStripe
  class CancelSubscriptionService < UserStripe::BaseService
    def execute(contract:)
      # すでに停止済みの場合はエラーを返す
      if contract.cancel_at_period_end
        raise Exceptions::Payment::AlreadyCanceled, 'すでに停止済みです'
      end

      # 現在のBillingProfileを取得
      current_billing_profile = contract.current_billing_profile
      raise Exceptions::Payment::NoCurrentBillingProfile unless current_billing_profile

      # Stripeのsubscriptionを取得
      stripe_subscription = current_billing_profile.chargeable
      raise Exceptions::Payment::NoStripeSubscription unless stripe_subscription

      # Stripe subscriptionの種類をチェック
      unless stripe_subscription.is_a?(StripeRecord::Subscription)
        raise Exceptions::Payment::InvalidPlanChange, 'Stripe subscriptionではありません'
      end


      if stripe_subscription.last_subscription_schedule.present?
        # 更新がスケジュールされている場合は、スケジュールを破棄
        subscription_schedule = Stripe::SubscriptionSchedule.retrieve(stripe_subscription.last_subscription_schedule.remote_id, stripe_api_key_config)
        if subscription_schedule.status == 'active'
          subscription_schedule.release
        end
      end
      ActiveRecord::Base.transaction do

        # Stripeでcancel_at_period_endをtrueに設定
        stripe_subscription_remote = Stripe::Subscription.update(
          stripe_subscription.remote_id,
          { cancel_at_period_end: true },
          stripe_api_key_config,
        )

        p 'stripe_subscription_remote'

        p stripe_subscription_remote



        # Contractのcancel_at_period_endフラグを更新
        contract.update!(
          cancel_at_period_end: true,
        )

        p contract

        # StripeRecord::Subscriptionのステータスを更新
        stripe_subscription.update!(
          status: stripe_subscription_remote.status,
        )

        p stripe_subscription

      end
      contract
    rescue Stripe::StripeError => e
      p 'Stripe::StripeError'
      p e

      raise e
      # Stripeエラーの場合
    rescue => e
      p 'その他のエラー'
      p e

      raise e
    end
  end
end
