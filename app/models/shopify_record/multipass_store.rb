# typed: strict

module ShopifyRecord
  class MultipassStore < ApplicationRecord
    extend T::Sig
    include Multitenancy
  end
end
