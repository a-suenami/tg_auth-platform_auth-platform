# typed: strict

class Ruler < ApplicationRecord
  extend T::Sig
  include Auth0Connectable

  private

  sig { returns(String) }
  def auth0_client_id
    Settings.ruler.auth0.auth0_client_id
  end

  sig { returns(String) }
  def auth0_client_secret
    Settings.ruler.auth0.auth0_client_secret
  end

  sig { returns(String) }
  def auth0_domain
    Settings.ruler.auth0.auth0_domain
  end

  sig { returns(String) }
  def auth0_connection_name
    Settings.ruler.auth0.auth0_connection_name
  end
end
