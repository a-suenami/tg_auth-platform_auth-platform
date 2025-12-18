# typed: false

module Deliveries
  module Concerns
    module TenantContext
      extend ActiveSupport::Concern

      # Set tenant context by tenant_id for background jobs
      # This should be called at the start of each worker's perform method
      def set_tenant_context_by_id(tenant_id)
        tenant = Tenant.find(tenant_id)
        RequestStore.store[:current_tenant_domain] = tenant.domain
        Tenant.current
      end
    end
  end
end
