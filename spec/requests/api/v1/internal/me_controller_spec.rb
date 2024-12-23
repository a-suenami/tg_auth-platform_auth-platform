# typed: false

RSpec.describe '[ Password API ]' do
  describe 'GET /api/v1/internal/me' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil, email_verified: true)
    }
    let(:current_user_profile) {
      create(:user_profile, tenant_id: current_tenant.id, user_id: current_user.id)
    }
    let(:current_user_contact_address) {
      create(:contact_address, tenant_id: current_tenant.id, user_id: current_user.id)
    }

    before do
      current_user
      current_user_profile
      current_user_contact_address
    end

    context 'when no session' do
      it 'returns 401' do
        is_expected.to eq 401
      end
    end

    context 'when present session' do
      include_context 'current user session is present'

      it 'returns 200' do
        is_expected.to eq 200
        expect(body_hash['id']).to eq(current_user.id)
        expect(body_hash['email']).to eq(current_user.email)
        expect(body_hash['enabled']).to be(true)
        expect(body_hash['email_verified']).to be(true)
        expect(body_hash['profile']['first_name']).to eq(current_user_profile.first_name)
      end
    end
  end

  describe 'DELETE /api/v1/internal/me' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil, email_verified: true)
    }
    let(:current_user_profile) {
      create(:user_profile, tenant_id: current_tenant.id, user_id: current_user.id)
    }
    let(:current_user_contact_address) {
      create(:contact_address, tenant_id: current_tenant.id, user_id: current_user.id)
    }

    before do
      current_user
      current_user_profile
      current_user_contact_address
    end

    context 'when no session' do
      it 'returns 401' do
        is_expected.to eq 401
      end
    end

    context 'when present session' do
      include_context 'current user session is present'

      it 'returns 204' do
        is_expected.to eq 204
        expect(User.find_by(id: current_user.id).deleted_at).not_to be_nil
      end
    end

    context 'when present shopify customer' do
      let(:shopify_customer) {
        create(:shopify_record__customer, tenant_id: current_tenant.id, user_id: current_user.id)
      }

      let(:client) { instance_double(AppShopify::Customer) }

      before do
        shopify_customer
        allow(AppShopify::Customer).to receive(:new).and_return(client)
        allow(client).to receive(:request_data_erasure)
        allow(client).to receive(:unsubscribe_email_marketing)
      end

      include_context 'current user session is present'

      it 'returns 204' do
        is_expected.to eq 204
        expect(User.find_by(id: current_user.id).deleted_at).not_to be_nil
        expect(client).to have_received(:request_data_erasure).with(shopify_customer.remote_id).once
        expect(client).to have_received(:unsubscribe_email_marketing).with(shopify_customer.remote_id).once
      end
    end
  end
end
