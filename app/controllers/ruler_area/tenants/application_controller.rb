# frozen_string_literal: true

module RulerArea::Tenants
  class ApplicationController < RulerArea::ApplicationController
    include Pagy::Backend

    before_action :set_tenant

    def root; end

    private

    def set_tenant
      RequestStore.store[:current_tenant_domain] = Tenant.find(params[:tenant_id]).domain || '-'
      @tenant_id = params[:tenant_id]
      @tenant = Tenant.current
      Tenant.current
    end
  end
end
