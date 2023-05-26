# typed: false

FactoryBot.define do
  factory :user do
    password { 'password' }
    password_digest { BCrypt::Password.create(password) }
    tenant_id { create(:tenant).id }
    sequence(:email) { |n| "test#{n}@example.com" }
    enabled { true }
  end
end
