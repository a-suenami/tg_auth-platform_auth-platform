# typed: strict

class DeliveryAddress < ApplicationRecord
  extend T::Sig
  include Multitenancy
  include AddressUtilisable

  belongs_to :user, inverse_of: :delivery_addresses

  validates :contact_tel, phone: { allow_blank: true }
end
