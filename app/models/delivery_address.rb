# typed: strict

class DeliveryAddress < ApplicationRecord
  extend T::Sig
  include Multitenancy
  include AddressUtilisable

  # 日本住所の場合のみ、バリデーションを行う
  with_options if: :domestic_address? do
    validates :zip_code, presence: true
    validates :zip_code, format: { with: /\A\d{3}-\d{4}\z/ }, allow_blank: true
    validates :prefecture_code, presence: true
    validates :city, presence: true
    validates :street, presence: true
  end

  validates :country_code, inclusion: { in: ISO3166::Country.all.map(&:alpha2) }, allow_blank: true # rubocop:disable Naming/VariableNumber
  attribute :country_code, default: 'JP'

  sig { returns(T::Boolean) }
  def domestic_address?
    country_code == 'JP'
  end

  belongs_to :user, inverse_of: :delivery_addresses

  validates :phone_number, phone: { allow_blank: true }

  sig { returns(T.nilable(String)) }
  def prefecture_code_jis
    format('%02d', self.prefecture_code) if self.prefecture_code.present?
  end
end
