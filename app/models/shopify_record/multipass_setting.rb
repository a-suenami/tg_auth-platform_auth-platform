# typed: strict

module ShopifyRecord
  class MultipassSetting < ApplicationRecord
    extend T::Sig
    include Multitenancy
  end
end
