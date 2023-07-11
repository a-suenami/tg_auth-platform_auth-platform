# typed: strict

class OauthAccessToken < ApplicationRecord
  extend T::Sig
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::AccessToken
  include Multitenancy

  after_create :update_linked_application

  sig { returns(T::Boolean) }
  def update_linked_application
    return false if self.resource_owner_id.blank?
    return false unless User.find(self.resource_owner_id).present?
    return false unless OauthApplication.find(self.application_id).present?

    linked_application = Users::LinkedApplication.find_or_initialize_by(tenant_id: self.tenant_id, user_id: self.resource_owner_id, oauth_application_id: self.application_id)
    old_scopes = linked_application.scopes.present? ? linked_application.scopes.split : []
    new_scopes = self.scopes.present? ? self.scopes.to_s.split : []
    linked_application.scopes = (old_scopes | new_scopes).join(' ')
    linked_application.last_linked_at = Time.zone.now
    linked_application.save
  end
end
