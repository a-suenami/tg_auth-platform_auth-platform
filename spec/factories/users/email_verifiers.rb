# typed: false

FactoryBot.define do
  factory :users__email_verifier, class: 'Users::EmailVerifier' do
    tenant_id { create(:tenant).id }
    user { create(:user) }
    code { '123456' }
    expired_at { 1.hour.from_now }
    remaining_attempts { 5 }
    verifier_type { 'registration' }
    email { user.email }
    used_at { nil }
  end
end
