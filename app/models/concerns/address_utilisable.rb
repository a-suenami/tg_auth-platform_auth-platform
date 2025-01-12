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
  end
end
