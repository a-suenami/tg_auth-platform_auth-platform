# typed: false

FactoryBot.define do
  factory :users__password_resets, class: 'Users::PasswordReset' do
    tenant_id { create(:tenant).id }
    user { create(:user) }
    code { 'hogehoge' }
    expired_at { 1.hour.from_now }
    used_at { nil }
  end
end
