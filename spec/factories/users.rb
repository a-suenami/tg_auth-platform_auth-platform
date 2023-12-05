# typed: false

FactoryBot.define do
  factory :user do
    password { 'Password1234!' }
    password_digest { BCrypt::Password.create(password) }
    tenant_id { create(:tenant).id }
    sequence(:email) { |n| "test#{n}@example.com" }
    enabled { true }
    phone_number { '09012345678' }
    deleted { false }
  end
end
