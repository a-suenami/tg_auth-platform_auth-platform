# typed: false

# ==============================================================================
# app - services - user stripe - base service
# ==============================================================================
module UserStripe
  class BaseService < ::BaseService
    def validate_before_subscribing_and_initialize_stripe_subscription(user:, stripe_record_price:)
      # TODO: memberships_usersを確認してチェックする
      # raise Exceptions::Payment::AlreadyHaveSubscriptions if user.premium_member?

      stripe_subscription = user.stripe_subscriptions.new
      stripe_subscription.tenant_id = Tenant.current.id
      stripe_subscription.price = stripe_record_price
      stripe_subscription.product = stripe_subscription.price.product
      default_payment_method_or_default_source = fetch_default_payment_method_or_default_source_of(user)

      raise Exceptions::Payment::InvalidPlan if stripe_subscription.product.deleted?
      raise Exceptions::Payment::InvalidPlan if stripe_subscription.price.deleted?
      raise Exceptions::Payment::CardMissing if default_payment_method_or_default_source.blank?


      stripe_subscription
    end

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

      @fetch_default_payment_method_or_default_source_of ||= stripe_customer.invoice_settings&.default_payment_method || stripe_customer&.default_source
    end

    def get_card_fingerprint(default_payment_method_or_default_source)
      card_fingerprint = case default_payment_method_or_default_source
      when Stripe::PaymentMethod
        default_payment_method_or_default_source.card&.fingerprint
      when Stripe::Card
        default_payment_method_or_default_source&.fingerprint
      else
        raise Exceptions::Payment::CardMissing
      end

      card_fingerprint
    end
  end
end
