# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :user_tag do
    tenant
    sequence(:name) { |n| "tag_#{n}" }
    description { 'Test tag description' }
    association :created_by, factory: :admin
    integration_enabled { false }

    trait :integration_enabled do
      integration_enabled { true }
    end
  end
end
