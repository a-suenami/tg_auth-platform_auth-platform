# typed: false

FactoryBot.define do
  factory :users__sms_verifier, class: 'Users::SmsVerifier' do
    tenant_id { create(:tenant).id }
    user { create(:user) }
    code { '123456' }
    expired_at { 1.hour.from_now }
    remaining_attempts { 5 }
    verifier_type { 'registration' }
    phone_number { "+8190#{format('%08<number>d', number: rand(0..99_999_999))}" }
    used_at { nil }
    ip_address { "#{rand(1..254)}.#{rand(1..254)}.#{rand(1..254)}.#{rand(1..254)}" }
  end
end
