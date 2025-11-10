# typed: false

FactoryBot.define do
  factory :user_profile do
    tenant_id { create(:tenant).id }
    user { create(:user, tenant_id: self.tenant_id) }
    first_name { '太郎' }
    last_name { '山田' }
    first_name_kana { 'タロウ' }
    last_name_kana { 'ヤマダ' }
    birth_date { Date.parse('1990-01-01') }
    gender { 'male' }
  end
end
