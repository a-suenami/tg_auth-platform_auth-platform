# typed: false

FactoryBot.define do
  factory :shopify_record__multipass_setting, class: 'ShopifyRecord::MultipassSetting' do
    tenant_id { create(:tenant).id }
    store_url { 'https://example.shopify.com' }
    store_name { 'store_name' }
    api_key { 'this_is_shopify_api_key' }
    oauth_client_id { 'this_is_oauth_client_id' }
    scopes { 'scopes' }
    multipass_secret { 'this_is_multipass_secret' }
    webhook_token { 'this_is_webhook_token' }
  end
end
