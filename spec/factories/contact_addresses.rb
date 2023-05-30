# typed: false

FactoryBot.define do
  factory :contact_address do
    tenant_id { create(:tenant).id }
    user { create(:user) }
    zip_code { '155-0033' }
    prefecture_code { '13' }
    city { '世田谷区代田' }
    address_1 { '1-1-1' }
    address_2 { '代田アモーレ 101号室' }
  end
end
