# typed: false

require 'stripe'

RSpec.describe 'API::V1::Internal::Me::CardsController' do
  include RequestHelpers

  let(:tenant_stripe_account) { create(:tenant_stripe_account, :with_account, tenant_id: current_tenant.id) }
  let(:current_user_stripe_payment_method) {
    create(:stripe_record_payment_method, tenant_id: current_tenant.id, user: current_user, type: 'card', api_key_account: tenant_stripe_account.stripe_account, remote_id: 'pm_test123')
  }

  before do
    allow(Tenant).to receive(:current!).and_return(current_tenant)
    allow(current_tenant).to receive(:tenant_stripe_account).and_return(tenant_stripe_account)
  end

  include_context 'current user session is present'

  describe 'POST /api/v1/internal/me/card/off_session_setup_intent' do
    context 'when successful' do
      let(:setup_intent) do
        create(:stripe_record_setup_intent, tenant_id: current_tenant.id, user: current_user, remote_id: 'seti_test123', client_secret: 'seti_test123_secret',
api_key_account: tenant_stripe_account.stripe_account,)
      end

      before do
        current_user_stripe_payment_method # カードを作成
        allow(StripeRecord::SetupIntent).to receive(:api_create_off_session_setup_intent).and_return(Mangrove::Result.ok(setup_intent))
      end

      it 'creates a setup intent and returns client secret' do
        is_expected.to eq 201

        expect(body_hash['remote_id']).to eq('seti_test123')
        expect(body_hash['client_secret']).to eq('seti_test123_secret')
      end
    end

    context 'when no card exists' do
      it 'returns card missing error' do
        is_expected.to eq 400

        expect(body_hash[:error][:code]).to eq('card_missing')
        expect(body_hash[:error][:message]).to eq('利用可能なカードが登録されていません')
      end
    end

    context 'when Stripe API fails' do
      let(:stripe_error) { Stripe::StripeError.new('API Error') }

      before do
        current_user_stripe_payment_method # カードを作成
        allow(StripeRecord::SetupIntent).to receive(:api_create_off_session_setup_intent).and_return(Mangrove::Result.err(stripe_error))
      end

      it 'returns error response' do
        is_expected.to eq 400

        expect(body_hash[:error][:code]).to eq('stripe_error')
        expect(body_hash[:error][:message]).to eq('API Error')
      end
    end
  end
end
