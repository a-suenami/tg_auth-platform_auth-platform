# typed: false

FactoryBot.define do
  factory :delivery_address do
    tenant_id { create(:tenant).id }
    user { create(:user) }
    is_default { false }
    zip_code { '155-0033' }
    prefecture_code { '13' }
    city { '世田谷区' }
    address_1 { '代田1-1-1' }
    address_2 { '代田アモーレ 101号室' }
    contact_tel { '090-1234-5678' }
  end
end
