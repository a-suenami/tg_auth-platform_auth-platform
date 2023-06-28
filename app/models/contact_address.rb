# typed: strict

class ContactAddress < ApplicationRecord
  extend T::Sig
  include Multitenancy
  include JpPrefecture

  belongs_to :user, inverse_of: :contact_address

  validates :zip_code, presence: true
  validates :prefecture_code, presence: true
  validates :city, presence: true
  validates :street, presence: true

  jp_prefecture :prefecture_code
end
