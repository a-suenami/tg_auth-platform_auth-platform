# typed: false

# ==============================================================================
# app - services - user stripe - base service
# ==============================================================================
module Memberships
  class BaseService < ::BaseService
    def stripe_api_key_config
      { api_key: Tenant.current&.tenant_stripe_account&.stripe_account&.api_key&.secret_key }
    end


    def fetch_constants
      @tax_rate_id = Tenant.current&.tenant_stripe_account&.tax_rate_id
    end

    # invoice_settings に設定されている Stripe::PaymentMethod もしくは default_source (Stripe::Card) を返す
    def fetch_default_payment_method_or_default_source_of(user)
      # TODO: payment_customer_idがpayjpユーザの場合、stripeには投げてはいけない 後で直す
      stripe_customer = Stripe::Customer.retrieve(
        { id: user.payment_customer_id, expand: ['default_source', 'invoice_settings.default_payment_method'] },
        stripe_api_key_config,
      )

      @fetch_default_payment_method_or_default_source_of ||= stripe_customer&.invoice_settings&.default_payment_method || stripe_customer&.default_source
    end
  end
end
