# typed: false

FactoryBot.define do
  factory :user do
    password { 'Password1234!' }
    password_digest { BCrypt::Password.create(password) }
    tenant_id { create(:tenant).id }
    sequence(:email) { |n| "test#{n}@example.com" }
    enabled { true }
    phone_number { "+8190#{format('%08<number>d', number: rand(0..99_999_999))}" }
    deleted { false }
    deleted_at { nil }

    trait :skip_validate do
      to_create { |instance| instance.save(validate: false) }
    end
  end
end
