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

  # ---------------------------------------------------------------------------
  # GET /api/v1/internal/me/card (show)
  # ---------------------------------------------------------------------------
  describe 'GET /api/v1/internal/me/card' do
    before do
      # card_payment_gateway を Stripe に（匿名Structでenumを持つオブジェクトを返す）
      allow(current_tenant).to receive(:card_payment_gateway).and_return(
        Struct.new(:enum).new(Tenant::CardPaymentGatewayEnum::Stripe),
      )
      current_user_stripe_payment_method
      allow_any_instance_of(User).to receive(:valid_stripe_card_payment_method!).and_return(current_user_stripe_payment_method)
    end

    it 'returns current user card' do
      is_expected.to eq 200
      expect(body_hash['remote_id']).to eq('pm_test123')
      expect(body_hash['type']).to be_present
    end
  end

  # ---------------------------------------------------------------------------
  # POST /api/v1/internal/me/card/setup_intent (create_setup_intent)
  # ---------------------------------------------------------------------------
  describe 'POST /api/v1/internal/me/card/setup_intent' do
    context 'when successful' do
      let(:setup_intent) do
        create(:stripe_record_setup_intent, tenant_id: current_tenant.id, user: current_user, remote_id: 'seti_card123', client_secret: 'seti_card123_secret',
api_key_account: tenant_stripe_account.stripe_account,)
      end

      before do
        allow(StripeRecord::SetupIntent).to receive(:api_create_card_setup_intent).and_return(Mangrove::Result.ok(setup_intent))
      end

      it 'creates setup intent and returns client secret' do
        is_expected.to eq 201
        expect(body_hash['remote_id']).to eq('seti_card123')
        expect(body_hash['client_secret']).to eq('seti_card123_secret')
      end
    end

    context 'when Stripe API fails' do
      let(:stripe_error) { Stripe::StripeError.new('API Error') }

      before do
        allow(StripeRecord::SetupIntent).to receive(:api_create_card_setup_intent).and_return(Mangrove::Result.err(stripe_error))
      end

      it 'returns error response' do
        is_expected.to eq 400
        expect(body_hash[:error][:code]).to eq('stripe_error')
        expect(body_hash[:error][:message]).to eq('API Error')
      end
    end
  end

  # ---------------------------------------------------------------------------
  # PATCH /api/v1/internal/me/card (update)
  # ---------------------------------------------------------------------------
  describe 'PATCH /api/v1/internal/me/card' do
    let(:setup_intent) { create(:stripe_record_setup_intent, tenant_id: current_tenant.id, user: current_user, remote_id: 'seti_update123', api_key_account: tenant_stripe_account.stripe_account) }

    before do
      # DBに存在させる
      setup_intent
    end

    context 'when creation of card payment method succeeds' do
      let(:result_obj) { StripeRecord::SetupIntent::CreateCardPaymentMethodResult::Succeeded.new(current_user_stripe_payment_method) }
      let(:params) { { setup_intent_id: 'seti_update123' } }

      before do
        allow_any_instance_of(StripeRecord::SetupIntent).to receive(:create_card_payment_method).and_return(result_obj)
      end

      it 'registers card payment method and returns card json' do
        is_expected.to eq 200
        expect(body_hash['remote_id']).to eq('pm_test123')
      end
    end
  end

  # ---------------------------------------------------------------------------
  # POST /api/v1/internal/me/card/complete_off_session_card
  # ---------------------------------------------------------------------------
  describe 'POST /api/v1/internal/me/card/complete_off_session_card' do
    let(:setup_intent) { create(:stripe_record_setup_intent, tenant_id: current_tenant.id, user: current_user, remote_id: 'seti_complete123', api_key_account: tenant_stripe_account.stripe_account) }

    before do
      setup_intent
    end

    context 'when succeeds' do
      let(:result_obj) { StripeRecord::SetupIntent::CompleteOffSessionCardResult::Succeeded.new(setup_intent) }
      let(:params) { { setup_intent_id: 'seti_complete123' } }

      before do
        allow_any_instance_of(StripeRecord::SetupIntent).to receive(:complete_off_session_card).and_return(result_obj)
      end

      it 'returns setup_intent json' do
        is_expected.to eq 200
        expect(body_hash['remote_id']).to eq('seti_complete123')
      end
    end
  end

  # ---------------------------------------------------------------------------
  # DELETE /api/v1/internal/me/card (destroy)
  # ---------------------------------------------------------------------------
  describe 'DELETE /api/v1/internal/me/card' do
    before do
      allow(current_tenant).to receive(:card_payment_gateway).and_return(
        Struct.new(:enum).new(Tenant::CardPaymentGatewayEnum::Stripe),
      )
      allow_any_instance_of(User).to receive(:detach_stripe_payment_methods).and_return(Mangrove::Result.ok(true))
    end

    it 'detaches card and returns 204' do
      is_expected.to eq 204
    end
  end
end
