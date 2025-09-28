# typed: strict

# ==============================================================================
# app/models/stripe_record/product.rb
# ==============================================================================
class StripeRecord
  class Product < ApplicationRecord
    extend T::Sig
    include Multitenancy

    has_many :prices, class_name: 'StripeRecord::Price', inverse_of: :product
  end
end
