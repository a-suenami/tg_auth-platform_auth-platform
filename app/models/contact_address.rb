# typed: strict

class ContactAddress < ApplicationRecord
  extend T::Sig
  include Multitenancy
  include JpPrefecture

  belongs_to :user, inverse_of: :contact_address

  validates :zip_code, presence: true
  validates :prefecture_code, presence: true
  validates :city, presence: true
  validates :address_1, presence: true
  validates :country_code, inclusion: { in: ISO3166::Country.all.map(&:alpha2) }, allow_blank: true # rubocop:disable Naming/VariableNumber

  jp_prefecture :prefecture_code
end
