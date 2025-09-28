# typed: false

FactoryBot.define do
  factory :memberships__plan, class: 'Memberships::Plan' do
    tenant_id { create(:tenant).id }
    sequence(:name) { |n| "plan_#{n}" }
    recurrence { [true, false].sample }
    recurring_interval_unit { %w[day week month year].sample }
    recurring_interval_count { rand(1..12) }
    billing_anchor { 'by_start_day' }
    anchor_day_of_month { nil }
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

    trait :daily do
      recurring_interval_unit { 'day' }
      recurring_interval_count { 1 }
    end

    trait :weekly do
      recurring_interval_unit { 'week' }
      recurring_interval_count { 1 }
    end

    trait :monthly do
      recurring_interval_unit { 'month' }
      recurring_interval_count { 1 }
    end

    trait :yearly do
      recurring_interval_unit { 'year' }
      recurring_interval_count { 1 }
    end

    trait :inactive do
      is_active { false }
      disabled_at { Time.current }
    end
  end
end
