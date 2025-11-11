# typed: false

# ==============================================================================
# app - workers - stripe subscription validation worker
# ==============================================================================
class StripeSubscriptionValidationWorker
  extend T::Sig

  include Sidekiq::Worker
  sidekiq_options queue: :stripe, retry: false, lock: :until_executed, lock_ttl: 30.minutes.to_i
  def perform
    ActiveRecord::Base.uncached do
      tenants = Tenant.all
      tenants.each do |tenant|
        # テナントのドメインセット
        RequestStore.store[:current_tenant_domain] = tenant.domain
        # RequestStore.store[:current_tenant]定義するためcurrentは事前に呼び出し必須
        Tenant.current

        tenant_stripe_account = tenant.tenant_stripe_account

        # 1. tenant_stripe_accountが存在しない場合はstripe決済を利用してないとしてスキップ
        next unless tenant_stripe_account

        # 2. api_keyが存在しない場合はスキップ
        request_options = AppStripe.request_options
        next unless request_options.present? && request_options.api_key.present?

        # 期限（expires_at）が切れている subscription を抽出
        subscriptions = StripeRecord::Subscription
          .where(status: 'active')
          .where('current_period_end < ?', Time.zone.now)
        subscriptions.each do |subscription|
          UserStripe::RenewMembershipSubscriptionService.new.execute(subscription:)
        end
      end
    end
  end
end
