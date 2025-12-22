# typed: false

FactoryBot.define do
  factory :membership do
    tenant_id { create(:tenant).id }
    sequence(:name) { |n| "membership_#{n}" }
    sequence(:display_name) { |n| "メンバーシップ#{n}" }
    position { rand(0..100) }
    tier { rand(1..5) }
    membership_group { nil }

    trait :with_group do
      membership_group
    end
  end
end
