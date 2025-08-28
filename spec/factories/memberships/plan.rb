# typed: false

FactoryBot.define do
  factory :memberships__plan, class: 'Memberships::Plan' do
    tenant_id { create(:tenant).id }
    sequence(:name) { |n| "plan_#{n}" }
    recurrence { [true, false].sample }
    validity_period { %w[month year].sample }
    amount { rand(1000..10_000) }
    is_active { true }
    enabled_at { Time.current }
    disabled_at { nil }
    trial_period_days { rand(0..30) }
    position { rand(0..100) }

    trait :recurring do
      recurrence { true }
    end

    trait :one_time do
      recurrence { false }
    end

    trait :monthly do
      validity_period { 'month' }
    end

    trait :yearly do
      validity_period { 'year' }
    end

    trait :inactive do
      is_active { false }
      disabled_at { Time.current }
    end
  end
end

