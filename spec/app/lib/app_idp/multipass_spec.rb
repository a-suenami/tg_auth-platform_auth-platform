# typed: false
# frozen_string_literal: true

RSpec.describe AppIdp::Multipass do
  describe 'AppIdp::Multipass.generate' do
    subject(:multipass_generator) { described_class.new.generate(multipass_store, current_user, return_to, remote_ip) }

    let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com') }
    let(:multipass_store) { create(:shopify_record__multipass_store, tenant_id: current_tenant.id) }
    let(:current_user) { create(:user, tenant_id: current_tenant.id, email: current_email) }
    let(:current_email) { 'test@example.com' }
    let(:user_profile) { create(:user_profile, tenant_id: current_tenant.id, user: current_user) }
    let(:return_to) { 'https://example.com' }
    let(:remote_ip) { '111.111.111.111' }

    let(:app_shopify_customer) { instance_double(AppShopify::Customer) }

    before do
      RequestStore.store[:current_tenant_domain] = "#{current_tenant.id}.localhost.com" || '-'
      # AppShopify::Customer.new.update_emailが呼ばれたかどうかのスパイ
      allow(AppShopify::Customer).to receive(:new).and_return(app_shopify_customer)
      allow(app_shopify_customer).to receive(:update_email).and_return(nil)
      user_profile
    end

    context 'When a new user logs in for the first time' do
      context 'When there is no other customer with the same email address' do
        it 'returns a multipass URL' do
          expect(multipass_generator).to be_a(String)
          # AppShopify::Customerが呼ばれないこと
          expect(app_shopify_customer).not_to have_received(:update_email)
        end
      end

      context 'When there is another customer with the same email address' do
        let(:other_user) { create(:user, tenant_id: current_tenant.id) }
        let(:other_user_shopify_record__customer) {
          create(:shopify_record__customer, tenant_id: current_tenant.id, user: other_user, remote_id: '1234567890123', email: current_user.email, multipass_store:,
store_name: multipass_store.store_name,)
        }

        before do
          other_user
          other_user_shopify_record__customer
        end

        it 'returns a multipass URL' do
          expect(multipass_generator).to be_a(String)
          # AppShopify::Customer#update_emailが呼ばれること
          expect(app_shopify_customer).to have_received(:update_email).with("gid://shopify/Customer/#{other_user_shopify_record__customer.remote_id}",
"disabled+#{other_user.id}@disabled.twogate-idp.com",)
        end
      end
    end

    context 'When an existing user logs in' do
      let(:current_user_shopify_record__customer) {
        create(:shopify_record__customer, tenant_id: current_tenant.id, user: current_user, remote_id: '1234567890123', email: current_email, multipass_store:, store_name: multipass_store.store_name)
      }

      before do
        current_user_shopify_record__customer
      end

      context 'When the email address is not changed' do
        it 'returns a multipass URL' do
          expect(multipass_generator).to be_a(String)
          # AppShopify::Customerが呼ばれないこと
          expect(app_shopify_customer).not_to have_received(:update_email)
        end
      end

      context 'When the email address is changed' do
        let(:current_email) { 'changed@example.com' }
        let(:current_user_shopify_record__customer) {
          create(:shopify_record__customer, tenant_id: current_tenant.id, user: current_user, remote_id: '1234567890123', email: 'old@example.com', multipass_store:,
store_name: multipass_store.store_name,)
        }

        it 'returns a multipass URL' do
          expect(multipass_generator).to be_a(String)
          # AppShopify::Customer#update_emailが呼ばれること
          expect(app_shopify_customer).to have_received(:update_email).with("gid://shopify/Customer/#{current_user_shopify_record__customer.remote_id}", current_email)
        end
      end

      context 'When other multipass store customer has the same email address' do
        let(:other_multipass_store) { create(:shopify_record__multipass_store, tenant_id: current_tenant.id, store_name: 'other_store_name') }
        let(:other_multipass_store_customer) {
          create(:shopify_record__customer, tenant_id: current_tenant.id, user: current_user, remote_id: '1234567890123', email: current_email, multipass_store:,
store_name: other_multipass_store.store_name,)
        }

        before do
          other_multipass_store
          other_multipass_store_customer
        end

        it 'returns a multipass URL' do
          expect(multipass_generator).to be_a(String)
          # AppShopify::Customerが呼ばれないこと
          expect(app_shopify_customer).not_to have_received(:update_email)
        end
      end
    end
  end
end
