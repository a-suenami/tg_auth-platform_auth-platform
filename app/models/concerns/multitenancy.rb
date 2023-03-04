# typed: strict

module Multitenancy
  extend ActiveSupport::Concern

  module ClassMethods
    extend T::Sig
    sig { returns(T.nilable(ActiveRecord::Relation)) }
    def default_scope
      T.bind(self, ActiveRecord::Querying)
      where(tenant_id: RequestStore.store[:current_tenant]) if RequestStore.store[:current_tenant].present?
    end
  end
end
