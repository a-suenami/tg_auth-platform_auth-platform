# frozen_string_literal: true

module TenantsArea
  class ApplicationController < ActionController::Base
    include Pagy::Backend

    before_action :set_tenant

    private

    def set_tenant
      RequestStore.store[:current_tenant_domain] = request.host || '-'
      Tenant.current
    end
  end
end
