# typed: strict

module Tenants
  class CreateService < BaseService
    sig { returns(T::Boolean) }
    def execute
      tenant = Tenant.create(T.let(params, T::Hash[T.untyped, T.untyped]))
      TenantSetting.find_or_create_by(tenant_id: tenant.id)
      tenant.persisted?
    end
  end
end
