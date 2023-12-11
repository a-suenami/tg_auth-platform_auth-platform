# typed: false

module Tenants
  class CreateService < BaseService
    def execute
      tenant = Tenant.create(params)
      tenant_setting = TenantSetting.find_or_create_by(tenant_id: tenant.id)
      tenant.persisted?
    end
  end
end
