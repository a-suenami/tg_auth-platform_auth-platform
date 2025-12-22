# typed: false

module Webhook::Komoju
  class BaseService < ::BaseService
    private

    def set_tenant_from_payment(payment)
      tenant = Tenant.find(payment.tenant_id)
      RequestStore.store[:current_tenant_domain] = tenant.domain
      RequestStore.store[:current_tenant] = tenant.id
      RequestStore.store[:current_tenant_object] = tenant
    end
  end
end
