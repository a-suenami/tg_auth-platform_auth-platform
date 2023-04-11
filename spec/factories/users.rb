# typed: false

FactoryBot.define do
  factory :user do
    password { 'password' }
    password_confirmation { 'password' }
    tenant_id { create(:tenant).id }
    sequence(:email) { |n| "test#{n}@example.com" }
    uid { SecureRandom.uuid }
  end
end
