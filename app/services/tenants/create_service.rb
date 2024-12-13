# typed: strict

module Tenants
  class CreateService < BaseService
    sig { returns(T::Boolean) }
    def execute
      tenant = Tenant.create(params)
      TenantSetting.find_or_create_by(tenant_id: tenant.id)
      tenant.persisted?
    end
  end
end
