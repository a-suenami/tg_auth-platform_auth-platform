# typed: false

FactoryBot.define do
  factory :shopify_record__customer, class: 'ShopifyRecord::Customer' do
    tenant_id { create(:tenant).id }
    user { create(:user) }
    remote_id { '1234567890123' }
    email { 'test@example.com' }
    tags { '' }
  end
end
