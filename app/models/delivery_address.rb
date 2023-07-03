# typed: strict

class DeliveryAddress < ApplicationRecord
  extend T::Sig
  include Multitenancy
  include JpPrefecture

  belongs_to :user, inverse_of: :delivery_addresses

  validates :zip_code, presence: true
  validates :prefecture_code, presence: true
  validates :city, presence: true
  validates :address_1, presence: true
  validates :country_code, inclusion: { in: ISO3166::Country.all.map(&:alpha2) }, allow_blank: true # rubocop:disable Naming/VariableNumber
  validates :contact_tel, phone: { allow_blank: true }

  jp_prefecture :prefecture_code

  sig { returns(String) }
  def prefecture_code_jis
    format('%02d', self.prefecture_code)
  end
end
