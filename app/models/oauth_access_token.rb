# typed: strict

class OauthAccessToken < ApplicationRecord
  extend T::Sig
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::AccessToken
  include Multitenancy

  after_create :update_linked_application

  belongs_to :resource_owner, class_name: 'User', optional: true

  sig { returns(T::Boolean) }
  def update_linked_application
    Users::LinkedApplications::UpdateService.new.execute(tenant_id: self.tenant_id, resource_owner_id: self.resource_owner_id, oauth_application_id: self.application_id,
scopes: T.let(self.scopes, T.nilable(Doorkeeper::OAuth::Scopes)),)
  end
end
