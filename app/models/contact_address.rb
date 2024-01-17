# typed: strict

class ContactAddress < ApplicationRecord
  extend T::Sig
  include Multitenancy
  include AddressUtilisable

  validates :phone_number, phone: { allow_blank: true }

  belongs_to :user, inverse_of: :contact_address

  sig { returns(T.nilable(String)) }
  def prefecture_code_jis
    # T.bind(self, T.class_of(AddressUtilisable))
    format('%02d', self.prefecture_code) if self.prefecture_code.present?
  end
end
