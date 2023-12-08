# typed: true

module AddressUtilisable
  extend T::Sig

  sig { returns(T.nilable(String)) }
  def country_code; end
end
