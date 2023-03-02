# typed: false

module Multitenancy
  extend ActiveSupport::Concern

  module ClassMethods
    def default_scope
      where(tenant_id: RequestStore.store[:current_tenant]) if RequestStore.store[:current_tenant].present?
    end
  end
end
