# typed: strict

class ContactAddress < ApplicationRecord
  extend T::Sig
  include Multitenancy
  include AddressUtilisable

  belongs_to :user, inverse_of: :contact_address
end
