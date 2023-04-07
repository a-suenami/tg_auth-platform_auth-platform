# typed: strict

class DelivaryAddress < ApplicationRecord
  extend T::Sig
  include Multitenancy
  include JpPrefecture

  belongs_to :user, inverse_of: :delivary_addresses

  jp_prefecture :prefecture_code
end
