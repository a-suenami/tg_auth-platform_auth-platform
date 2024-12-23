# typed: strict

class OauthAccessToken < ApplicationRecord
  extend T::Sig

  sig { returns(T.nilable(Doorkeeper::OAuth::Scopes)) }
  def scopes; end
end
