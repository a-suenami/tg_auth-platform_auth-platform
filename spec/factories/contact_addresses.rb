# typed: false

FactoryBot.define do
  factory :contact_address do
    tenant_id { create(:tenant).id }
    user { create(:user) }
    zip_code { '1550033' }
    prefecture_code { '13' }
    city { '世田谷区代田' }
    street { '1-1-1' }
    building { '代田アモーレ 101号室' }
    phone_number { '090-1234-5678' }
    country_code { 'JP' }
  end
end
