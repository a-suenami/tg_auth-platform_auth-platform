# typed: strict

module ShopifyRecord
  class Customer < ApplicationRecord
    extend T::Sig
    include Multitenancy

    belongs_to :multipass_store, class_name: 'ShopifyRecord::MultipassStore'
    belongs_to :user
  end
end
