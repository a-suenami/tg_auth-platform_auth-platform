# frozen_string_literal: true

module TenantsArea
  class ApplicationController < ActionController::Base
    include Pagy::Backend

    before_action :set_tenant

    private

    def set_tenant
      RequestStore.store[:current_tenant] = request.subdomain.split('.').first&.to_sym || '-'
      Tenant.current
    end
  end
end
