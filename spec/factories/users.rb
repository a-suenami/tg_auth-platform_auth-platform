# typed: false

FactoryBot.define do
  factory :user do
    password { 'password' }
    tenant_id { create(:tenant).id }
    sequence(:email) { |n| "test#{n}@example.com" }
    enabled { true }
  end
end
