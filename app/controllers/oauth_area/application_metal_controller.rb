# typed: true
# frozen_string_literal: true

# for Doorkeeper::TokenController
module OauthArea
  class ApplicationMetalController < ActionController::API
    before_action :set_tenant

    private

    def set_tenant
      RequestStore.store[:current_tenant_domain] = request.host || '-'
      Tenant.current
    end
  end
end
