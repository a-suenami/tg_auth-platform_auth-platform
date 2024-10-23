# typed: strict

module ShopifyRecord
  class Customer < ApplicationRecord
    extend T::Sig
    include Multitenancy

    belongs_to :user
  end
end
