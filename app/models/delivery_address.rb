# typed: strict

class DeliveryAddress < ApplicationRecord
  extend T::Sig
  include Multitenancy
  include AddressUtilisable

  belongs_to :user, inverse_of: :delivery_addresses

  validates :phone_number, phone: { allow_blank: true }

  sig { returns(String) }
  def prefecture_code_jis
    # T.bind(self, T.class_of(AddressUtilisable))
    format('%02d', self.prefecture_code)
  end
end
