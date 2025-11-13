# typed: false

FactoryBot.define do
  factory :shopify_record__customer, class: 'ShopifyRecord::Customer' do
    tenant_id { create(:tenant).id }
    user { create(:user, tenant_id: self.tenant_id) }
    multipass_store { create(:shopify_record__multipass_store, tenant_id: self.tenant_id) }
    store_name { 'store_name' }
    remote_id { '1234567890123' }
    email { 'test@example.com' }
    tags { nil }
  end
end
