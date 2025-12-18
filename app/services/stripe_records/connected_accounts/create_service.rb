# typed: false

# ==============================================================================
# app/services/stripe_records/connected_accounts/create_service.rb
# ==============================================================================
module StripeRecords
  module ConnectedAccounts
    class CreateService
      attr_reader :platform_account, :tenant

      def initialize(platform_account:, tenant:)
        @platform_account = platform_account
        @tenant = tenant
      end

      # Standard Connected Accountを作成する
      # @return [Mangrove::Result<StripeRecord::Account, String>]
      def execute
        api_key = platform_account.api_key
        return Mangrove::Result::Err.new('Platform account has no API key') if api_key.blank?

        begin
          # Standard accountを作成
          stripe_account = Stripe::Account.create(
            {
              type: 'standard',
            },
            { api_key: api_key.secret_key },
          )

          # StripeRecord::Accountに保存
          connected_account = StripeRecord::Account.new(
            tenant_id: tenant.id,
            remote_id: stripe_account.id,
            controlling_platform: platform_account,
          )

          if connected_account.save
            Mangrove::Result::Ok.new(connected_account)
          else
            Mangrove::Result::Err.new(connected_account.errors.full_messages.join(', '))
          end
        rescue Stripe::StripeError => e
          Mangrove::Result::Err.new("Stripe APIエラー: #{e.message}")
        end
      end
    end
  end
end
