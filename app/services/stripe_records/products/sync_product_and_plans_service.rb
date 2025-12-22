# typed: false

# ==============================================================================
# app - services - app stripes - sync product and plans service
# ==============================================================================
module StripeRecords
  class Products::SyncProductAndPlansService < StripeRecords::BaseService
    def execute(stripe_product_id:)
      stripe_product = StripeRecord::Client::Product.retrieve(stripe_product_id, stripe_account_id: @tenant_stripe_account.stripe_account_id_if_needed, api_key: @tenant_stripe_account.api_key)
      stripe_prices = StripeRecord::Client::Price.list({ product: stripe_product_id }, stripe_account_id: @tenant_stripe_account.stripe_account_id_if_needed, api_key: @tenant_stripe_account.api_key)

      stripe_recode_product = StripeRecord::Product.find_or_initialize_by(remote_id: stripe_product.ok_inner.id)

      ActiveRecord::Base.transaction do
        stripe_recode_product.update!(
          name: stripe_product.ok_inner.name,
          deleted: false, # Stripe 上で active かどうかに関わらず FanApp Base 側では deleted: false にする
        )

        stripe_prices.ok_inner.auto_paging_each do |stripe_price|
          app_stripe_price = StripeRecord::Price.find_or_initialize_by(remote_id: stripe_price.id)
          app_stripe_price.update!(
            product: StripeRecord::Product.find_by(remote_id: stripe_price.product),
            name: stripe_price.nickname,
            amount: stripe_price.unit_amount,
            interval: stripe_price.recurring.interval,
            interval_count: stripe_price.recurring.interval_count,
            deleted: !stripe_price.active,
          )
        end
      end
    end
  end
end
