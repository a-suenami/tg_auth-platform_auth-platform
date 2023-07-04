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
    validates :zip_code, presence: true
    validates :prefecture_code, presence: true
    validates :city, presence: true
    validates :address_1, presence: true
    validates :country_code, inclusion: { in: ISO3166::Country.all.map(&:alpha2) }, allow_blank: true # rubocop:disable Naming/VariableNumber

    sig { returns(T.nilable(String)) }
    def zip_code
      # 3文字目にハイフンを入れる
      super&.clone&.insert(3, '-')
    end
  end
end
