# typed: true

module Users::LinkedApplications
  class UpdateService < BaseService
    extend T::Sig

    sig { params(tenant_id: String, resource_owner_id: String, oauth_application_id: String, scopes: T.nilable(Doorkeeper::OAuth::Scopes)).returns(T::Boolean) }
    def execute(tenant_id:, resource_owner_id:, oauth_application_id:, scopes:)
      return false if User.active.find(resource_owner_id).blank?
      return false if OauthApplication.find(oauth_application_id).blank?
      return false if tenant_id.blank?

      linked_application = Users::LinkedApplication.find_or_initialize_by(tenant_id:, user_id: resource_owner_id, oauth_application_id:)
      old_scopes = linked_application.scopes.present? ? linked_application.scopes.split : []
      new_scopes = scopes.present? ? scopes.to_s.split : []
      linked_application.scopes = (old_scopes | new_scopes).join(' ')
      linked_application.last_linked_at = Time.zone.now
      linked_application.save
    end
  end
end
