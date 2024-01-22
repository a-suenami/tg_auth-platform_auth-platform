# typed: strict

module AddressUtilisable
  extend ActiveSupport::Concern
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ApplicationRecord }

  included do
    extend T::Sig
    extend T::Helpers
    include JpPrefecture

    T.bind(self, JpPrefecture::Base)
    jp_prefecture :prefecture_code

    T.bind(self, T.class_of(ApplicationRecord))
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
  end
end
