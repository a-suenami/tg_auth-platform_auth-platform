# typed: strict

class ContactAddress < ApplicationRecord
  extend T::Sig
  include Multitenancy
  include AddressUtilisable

  belongs_to :user, inverse_of: :contact_address

  sig { returns(String) }
  def prefecture_code_jis
    # T.bind(self, T.class_of(AddressUtilisable))
    format('%02d', self.prefecture_code)
  end
end
