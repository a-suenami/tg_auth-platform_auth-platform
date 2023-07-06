# typed: strict

class OauthAccessToken < ApplicationRecord
  extend T::Sig
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::AccessToken
  include Multitenancy

  after_create :update_linked_application

  sig { returns(T::Boolean) }
  def update_linked_application
    user = User.where(id: self.resource_owner_id)
    return false if user.empty?

    linked_application = Users::LinkedApplication.find_or_initialize_by(tenant_id: self.tenant_id, user_id: self.resource_owner_id, oauth_application_id: self.application_id)
    linked_application.scopes = (linked_application.scopes.split | self.scopes.to_s.split).join(' ')
    linked_application.last_linked_at = Time.zone.now
    linked_application.save
  end
end
