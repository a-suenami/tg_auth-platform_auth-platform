# typed: false

FactoryBot.define do
  factory :delivery_address do
    tenant_id { create(:tenant).id }
    user { create(:user) }
    is_default { false }
    zip_code { '155-0033' }
    prefecture_code { '13' }
    city { '世田谷区代田' }
    street { '1-1-1' }
    building_name { '代田アモーレ 101号室' }
    contact_tel { '090-1234-5678' }
  end
end
