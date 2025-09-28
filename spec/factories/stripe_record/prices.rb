# typed: false

FactoryBot.define do
  factory :stripe_record_price, class: 'StripeRecord::Price' do
    tenant_id { create(:tenant).id }
    product { create(:stripe_record_product, tenant_id: tenant_id) }

    sequence(:remote_id) { |n| "price_#{n}" }
    sequence(:name) { |n| "price_#{n}" }
    amount { 1000 }
    interval { 'month' }
    interval_count { 1 }
    trial_period_days { 0 }
    deleted { false }
    position { 1000 }
    displayed { true }

    trait :recurring do
      interval { 'month' }
      interval_count { 1 }
    end

    trait :one_time do
      interval { nil }
      interval_count { nil }
    end

    trait :daily do
      interval { 'day' }
      interval_count { 1 }
    end

    trait :weekly do
      interval { 'week' }
      interval_count { 1 }
    end

    trait :monthly do
      interval { 'month' }
      interval_count { 1 }
    end

    trait :yearly do
      interval { 'year' }
      interval_count { 1 }
    end

    trait :with_trial do
      trial_period_days { 7 }
    end

    trait :deleted do
      deleted { true }
    end

    trait :hidden do
      displayed { false }
    end
  end
end
