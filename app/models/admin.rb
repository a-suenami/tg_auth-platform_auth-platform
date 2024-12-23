# typed: strict

class Admin < ApplicationRecord
  extend T::Sig
  include Multitenancy
  include Auth0Connectable

  private

  sig { returns(String) }
  def auth0_client_id
    Settings.admin.auth0.auth0_client_id
  end

  sig { returns(String) }
  def auth0_client_secret
    Settings.admin.auth0.auth0_client_secret
  end

  sig { returns(String) }
  def auth0_domain
    Settings.admin.auth0.auth0_original_domain
  end

  sig { returns(String) }
  def auth0_connection_name
    Settings.admin.auth0.auth0_connection_name
  end
end
