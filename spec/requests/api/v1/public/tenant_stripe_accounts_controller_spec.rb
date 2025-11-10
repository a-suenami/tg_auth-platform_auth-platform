# typed: false
# frozen_string_literal: true

RSpec.describe '[ API::V1::Public::TenantStripeAccountsController API ]' do
  describe 'GET /api/v1/public/tenant_stripe_account' do
    context 'when tenant_stripe_account exists' do
      let(:tenant_stripe_account) { create(:tenant_stripe_account, :with_account, tenant_id: current_tenant.id) }

      before do
        tenant_stripe_account
      end

      it 'returns tenant stripe account with public_key' do
        is_expected.to eq 200

        expect(body_hash['tenant_id']).to eq(current_tenant.id)
        expect(body_hash['type']).to eq('Tenant::StripeAccount')
        expect(body_hash['publishable_key']).to eq('pk_test_1234567890')
      end
    end

    context 'when tenant_stripe_account does not exist' do
      before do
        current_tenant.update!(tenant_stripe_account: nil)
      end

      it 'returns 404' do
        is_expected.to eq 404
      end
    end
  end
end
