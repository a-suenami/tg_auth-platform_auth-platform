# typed: strict

module WebhookArea
  class ApplicationController < ActionController::API
    extend T::Sig

    before_action :set_tenant

    private

    sig { returns(T.nilable(Tenant)) }
    def set_tenant
      RequestStore.store[:current_tenant_domain] = request.host || '-'
      Tenant.current
    end

  end
end
