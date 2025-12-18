# typed: false

RSpec.describe StripeRecords::ConnectedAccounts::CreateService do
  subject(:execute) { described_class.new(platform_account: platform_account, tenant: tenant).execute }

  let(:tenant) { create(:tenant, id: :sample, name: 'Sample', domain: 'sample.localhost.com') }
  let(:api_key) { create(:stripe_record_api_key, :skip_validate, tenant_id: tenant.id) }
  let(:platform_account) { create(:stripe_record_account, :skip_validate, tenant_id: tenant.id, api_key: api_key) }

  before do
    RequestStore.store[:current_tenant_domain] = "#{tenant.id}.localhost.com"
  end

  describe '#execute' do
    context 'when Stripe API call succeeds' do
      let(:stripe_account_response) do
        double(
          id: 'acct_connected_123',
          type: 'standard',
          settings: double(
            dashboard: double(display_name: 'Connected Account'),
            payments: double(
              statement_descriptor: 'CONNECTED',
              statement_descriptor_kana: nil,
              statement_descriptor_kanji: nil,
            ),
          ),
          business_profile: double(name: 'Connected Business'),
        )
      end

      before do
        allow(Stripe::Account).to receive(:create).and_return(stripe_account_response)
        allow(Stripe::Account).to receive(:retrieve).and_return(stripe_account_response)
      end

      it 'creates a connected account' do
        result = execute

        expect(result).to be_ok
        connected_account = result.ok_inner
        expect(connected_account).to be_persisted
        expect(connected_account.remote_id).to eq('acct_connected_123')
        expect(connected_account.type).to eq('standard')
        expect(connected_account.controlling_platform).to eq(platform_account)
      end

      it 'calls Stripe API with correct parameters' do
        expect(Stripe::Account).to receive(:create).with(
          { type: 'standard' },
          { api_key: api_key.secret_key },
        )

        execute
      end
    end

    context 'when platform account has no API key' do
      let(:platform_account) { create(:stripe_record_account, :skip_validate, tenant_id: tenant.id, api_key: nil) }

      it 'returns an error' do
        result = execute

        expect(result).to be_err
        expect(result.err_inner).to eq('Platform account has no API key')
      end
    end

    context 'when Stripe API call fails' do
      before do
        allow(Stripe::Account).to receive(:create).and_raise(Stripe::StripeError.new('Invalid API key'))
      end

      it 'returns an error' do
        result = execute

        expect(result).to be_err
        expect(result.err_inner).to include('Stripe APIエラー')
      end
    end
  end
end
