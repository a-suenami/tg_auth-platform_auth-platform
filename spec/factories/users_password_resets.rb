# typed: false

FactoryBot.define do
  factory :users__password_resets, class: 'Users::PasswordReset' do
    tenant_id { create(:tenant).id }
    user { create(:user, tenant_id: self.tenant_id) }
    code { 'hogehoge' }
    expired_at { 1.hour.from_now }
    used_at { nil }
  end
end
