# typed: false

# ==============================================================================
# app/services/stripe_records/connected_accounts/create_account_link_service.rb
# ==============================================================================
module StripeRecords
  module ConnectedAccounts
    class CreateAccountLinkService
      attr_reader :connected_account, :refresh_url, :return_url

      def initialize(connected_account:, refresh_url:, return_url:)
        @connected_account = connected_account
        @refresh_url = refresh_url
        @return_url = return_url
      end

      # オンボーディング用のAccount Linkを作成する
      # @return [Mangrove::Result<Stripe::AccountLink, String>]
      def execute
        platform_account = connected_account.controlling_platform
        return Mangrove::Result::Err.new('Connected account has no controlling platform') if platform_account.blank?

        api_key = platform_account.api_key
        return Mangrove::Result::Err.new('Platform account has no API key') if api_key.blank?

        begin
          account_link = Stripe::AccountLink.create(
            {
              account: connected_account.remote_id,
              refresh_url: refresh_url,
              return_url: return_url,
              type: 'account_onboarding',
            },
            { api_key: api_key.secret_key },
          )

          Mangrove::Result::Ok.new(account_link)
        rescue Stripe::StripeError => e
          Mangrove::Result::Err.new("Stripe APIエラー: #{e.message}")
        end
      end
    end
  end
end
