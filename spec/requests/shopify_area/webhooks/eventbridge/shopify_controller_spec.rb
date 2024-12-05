# typed: false

RSpec.describe '[ ShopifyArea::Webhooks::Eventbridge::ShopifyController API ]' do
  describe 'PUT /shopify/webhooks/eventbridge/shopify' do
    let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com') }
    let(:multipass_store) { create(:shopify_record__multipass_store, tenant_id: current_tenant.id, store_name:) }
    let(:current_user) { create(:user, tenant_id: current_tenant.id, email: current_email) }
    let(:current_email) { 'test@example.com' }
    let(:user_profile) { create(:user_profile, tenant_id: current_tenant.id, user: current_user) }

    let(:store_name) { 'example-store' }

    before do
      RequestStore.store[:current_tenant_domain] = "#{current_tenant.id}.localhost.com" || '-'
      current_user
      user_profile
      multipass_store
    end

    context 'when given a valid params' do
      let(:event_topic) { 'customers/update' }
      let(:event_user_id) { current_user.id }
      let(:headers) {
        {
          'Authorization' => "Bearer #{multipass_store.webhook_token}",
        }
      }
      # rubocop:disable Naming/VariableNumber
      let(:params) {
        {
          version: '0',
          id: '14b41a2b-81a8-3f71-4a6b-29d64aa49424',
          'detail-type': 'shopifyWebhook',
          source: "aws.partner/shopify.com/123456789012/#{store_name}",
          account: '121212121212',
          time: '2024-12-05T03:04:48Z',
          region: 'ap-northeast-1',
          resources: [],
          detail: {
            payload: {
              id: 1_234_567_890_123,
              email: 'test@example.com',
              created_at: '2024-11-21T11:47:35+09:00',
              updated_at: '2024-12-05T12:04:47+09:00',
              first_name: '太郎',
              last_name: '山田',
              orders_count: 11,
              state: 'enabled',
              total_spent: '1570.00',
              last_order_id: 1_313_131_313_131,
              note: nil,
              verified_email: true,
              multipass_identifier: event_user_id,
              tax_exempt: false,
              tags: 'test_tag',
              last_order_name: '#1019',
              currency: 'JPY',
              phone: nil,
              addresses: [
                {
                  id: 1_414_141_414_141,
                  customer_id: 1_234_567_890_123,
                  first_name: '太郎',
                  last_name: '山田',
                  company: nil,
                  address1: '銀座1-1-1',
                  address2: 'ティロフィナーレ銀座101',
                  city: '中央区',
                  province: 'Tokyo',
                  country: 'Japan',
                  zip: '104-0061',
                  phone: '080-1234-5678',
                  name: '太郎 山田',
                  province_code: 'JP-13',
                  country_code: 'JP',
                  country_name: 'Japan',
                  default: true,
                },
              ],
              tax_exemptions: [],
              email_marketing_consent: {
                state: 'not_subscribed',
                opt_in_level: 'single_opt_in',
                consent_updated_at: nil,
              },
              sms_marketing_consent: nil,
              admin_graphql_api_id: 'gid://shopify/Customer/1234567890123',
              default_address: {
                id: 1_414_141_414_141,
                customer_id: 1_234_567_890_123,
                first_name: '太郎',
                last_name: '山田',
                company: nil,
                address1: '銀座1-1-1',
                address2: 'ティロフィナーレ銀座101',
                city: '中央区',
                province: 'Tokyo',
                country: 'Japan',
                zip: '104-0061',
                phone: '080-1234-5678',
                name: '太郎 山田',
                province_code: 'JP-13',
                country_code: 'JP',
                country_name: 'Japan',
                default: true,
              },
            },
            metadata: {
              'Content-Type': 'application/json',
              'X-Shopify-Topic': event_topic,
              'X-Shopify-Shop-Domain': "#{store_name}.myshopify.com",
              'X-Shopify-Hmac-SHA256': 'xxxxxxxx',
              'X-Shopify-Webhook-Id': '2b70bc39-d8ab-4792-936f-4dea65704b43',
              'X-Shopify-API-Version': '2024-10',
              'X-Shopify-Event-Id': '7a53163e-19f8-4f7d-ab32-5f7df441efc5',
              'X-Shopify-Triggered-At': '2024-12-05T03:04:47.103612672Z',
            },
          },
        }
      }
      # rubocop:enable Naming/VariableNumber

      context 'when event_topic is customers/create' do
        let(:event_topic) { 'customers/create' }

        it 'create customer' do
          expect(ShopifyRecord::Customer.where(tenant_id: current_tenant.id).count).to eq 0
          is_expected.to eq 204
          expect(ShopifyRecord::Customer.where(tenant_id: current_tenant.id).count).to eq 1
        end
      end

      context 'when event_topic is customers/update' do
        let(:shopify_record__customer) {
          create(:shopify_record__customer, tenant_id: current_tenant.id, user: current_user, remote_id: '1234567890123', email: current_email, multipass_store:,
store_name: multipass_store.store_name,)
        }

        before do
          shopify_record__customer
        end

        it 'update customer' do
          expect(ShopifyRecord::Customer.count).to eq 1
          expect(shopify_record__customer.tags).to eq ''
          is_expected.to eq 204
          expect(ShopifyRecord::Customer.count).to eq 1
          expect(shopify_record__customer.reload.tags).to eq 'test_tag'
        end
      end

      context 'when user is not found' do
        let(:event_user_id) { 'invalid_id' }

        it 'does not create customer' do
          expect(ShopifyRecord::Customer.count).to eq 0
          is_expected.to eq 204
          expect(ShopifyRecord::Customer.count).to eq 0
        end
      end
    end
  end
end
