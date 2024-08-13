# typed: false

module StripeRecords
  class Products::RetrieveService < StripeRecords::BaseService
    def execute(stripe_product_id:)
      stripe_product = StripeRecord::Client::Product.retrieve(stripe_product_id, stripe_account_id: @tenant_stripe_account.stripe_account_id_if_needed, api_key: @tenant_stripe_account.api_key)
      stripe_prices = StripeRecord::Client::Price.list({ product: stripe_product_id }, stripe_account_id: @tenant_stripe_account.stripe_account_id_if_needed, api_key: @tenant_stripe_account.api_key)

      stripe_record_product = StripeRecord::Product.new(
        tenant_id: @tenant_stripe_account.tenant_id,
        remote_id: stripe_product.ok_inner.id,
        name: stripe_product.ok_inner.name,
      )

      stripe_prices.ok_inner.auto_paging_each do |stripe_price|
        stripe_record_product.prices.new(
          tenant_id: @tenant_stripe_account.tenant_id,
          remote_id: stripe_price.id,
          name: stripe_price.nickname,
          amount: stripe_price.unit_amount,
          interval: stripe_price.recurring.interval,
          interval_count: stripe_price.recurring.interval_count,
          deleted: !stripe_price.active,
        )
      end

      stripe_record_product
    end
  end
end
