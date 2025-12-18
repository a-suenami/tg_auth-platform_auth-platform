# typed: false

RSpec.describe StripeRecords::ConnectedAccounts::CreateAccountLinkService do
  subject(:execute) do
    described_class.new(
      connected_account: connected_account,
      refresh_url: refresh_url,
      return_url: return_url,
    ).execute
  end

  let(:tenant) { create(:tenant, id: :sample, name: 'Sample', domain: 'sample.localhost.com') }
  let(:api_key) { create(:stripe_record_api_key, :skip_validate, tenant_id: tenant.id) }
  let(:platform_account) { create(:stripe_record_account, :skip_validate, tenant_id: tenant.id, api_key: api_key) }
  let(:connected_account) do
    create(:stripe_record_account, :skip_validate,
      tenant_id: tenant.id,
      remote_id: 'acct_connected_123',
      controlling_platform: platform_account,
    )
  end
  let(:refresh_url) { 'https://example.com/refresh' }
  let(:return_url) { 'https://example.com/return' }

  before do
    RequestStore.store[:current_tenant_domain] = "#{tenant.id}.localhost.com"
  end

  describe '#execute' do
    context 'when Stripe API call succeeds' do
      let(:account_link_response) do
        double(
          url: 'https://connect.stripe.com/setup/account/123',
          expires_at: Time.now.to_i + 3600,
        )
      end

      before do
        allow(Stripe::AccountLink).to receive(:create).and_return(account_link_response)
      end

      it 'creates an account link' do
        result = execute

        expect(result).to be_ok
        account_link = result.ok_inner
        expect(account_link.url).to eq('https://connect.stripe.com/setup/account/123')
      end

      it 'calls Stripe API with correct parameters' do
        expect(Stripe::AccountLink).to receive(:create).with(
          {
            account: 'acct_connected_123',
            refresh_url: refresh_url,
            return_url: return_url,
            type: 'account_onboarding',
          },
          { api_key: api_key.secret_key },
        )

        execute
      end
    end

    context 'when connected account has no controlling platform' do
      let(:connected_account) do
        create(:stripe_record_account, :skip_validate,
          tenant_id: tenant.id,
          remote_id: 'acct_standalone_123',
          controlling_platform: nil,
        )
      end

      it 'returns an error' do
        result = execute

        expect(result).to be_err
        expect(result.err_inner).to eq('Connected account has no controlling platform')
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
        allow(Stripe::AccountLink).to receive(:create).and_raise(Stripe::StripeError.new('Invalid account'))
      end

      it 'returns an error' do
        result = execute

        expect(result).to be_err
        expect(result.err_inner).to include('Stripe APIエラー')
      end
    end
  end
end
