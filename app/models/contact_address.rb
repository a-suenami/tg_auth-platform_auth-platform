# typed: strict

class ContactAddress < ApplicationRecord
  extend T::Sig
  include Multitenancy
  include AddressUtilisable

  belongs_to :user, inverse_of: :contact_address

  sig { returns(T.nilable(String)) }
  def prefecture_code_jis
    format('%02d', self.prefecture_code) if self.prefecture_code.present?
  end
end
