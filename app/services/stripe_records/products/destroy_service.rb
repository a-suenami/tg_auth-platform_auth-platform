# typed: false

module StripeRecords
  class Products::DestroyService < StripeRecords::BaseService
    def execute(stripe_record_product_id:)
      ActiveRecord::Base.transaction do
        stripe_record_product = StripeRecord::Product.find(stripe_record_product_id)
        stripe_record_product.update!(deleted: true)

        stripe_record_product.prices.update_all(deleted: true)
      end
    end
  end
end
