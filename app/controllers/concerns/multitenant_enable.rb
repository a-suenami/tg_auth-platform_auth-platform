module MultitenantEnable
  extend ActiveSupport::Concern

  included do
    before_action :set_tenant
  end

  def set_tenant
    RequestStore.store[:current_tenant_domain] = request.host || '-'
    Tenant.current
  end
end
