# typed: strict

class DeliveryAddress < ApplicationRecord
  extend T::Sig
  include Multitenancy
  include JpPrefecture

  belongs_to :user, inverse_of: :delivery_addresses

  jp_prefecture :prefecture_code
end
