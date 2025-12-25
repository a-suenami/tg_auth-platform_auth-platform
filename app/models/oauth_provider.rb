# typed: strict

class OauthProvider < ApplicationRecord
  extend T::Sig
  include Multitenancy

  validates :provider, :client_id, :client_secret, :auth_url, :token_url, presence: true
end
