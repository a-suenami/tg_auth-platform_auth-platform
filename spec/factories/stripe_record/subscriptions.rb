# typed: false

FactoryBot.define do
  factory :stripe_record_subscription, class: 'StripeRecord::Subscription' do
    tenant_id { create(:tenant).id }
    user { create(:user, tenant_id: self.tenant_id) }
    product { create(:stripe_record_product, tenant_id: self.tenant_id) }
    price { create(:stripe_record_price, product: product, tenant_id: self.tenant_id) }
    pending_setup_intent { nil }

    amount { 1000 }
    tax { 0 }
    currency { 'JPY' }
    refunded { false }
    refund_reason { nil }

    current_period_start { Time.current }
    current_period_end { 1.month.from_now }
    trial_end { nil }
    trial_start { nil }

    sequence(:remote_id) { |n| "sub_#{n}" }
    status { 'active' }

    trait :incomplete do
      status { 'incomplete' }
    end

    trait :trialing do
      status { 'trialing' }
      trial_start { Time.current }
      trial_end { 7.days.from_now }
    end

    trait :canceled do
      status { 'canceled' }
    end

    trait :past_due do
      status { 'past_due' }
    end

    trait :unpaid do
      status { 'unpaid' }
    end
  end
end
