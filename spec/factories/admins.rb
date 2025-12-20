# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :admin do
    tenant_id { create(:tenant).id }
    sequence(:name) { |n| "Admin #{n}" }
    sequence(:email) { |n| "admin#{n}@example.com" }
    sequence(:uid) { |n| "auth0|admin#{n}" }
  end
end
