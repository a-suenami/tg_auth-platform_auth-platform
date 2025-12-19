# typed: strict
# frozen_string_literal: true

# Multi-tenant feature flags using Flipper's actor system
#
# Simple architecture:
#   - Single feature (:delivery) with actor gates for per-tenant control
#   - Uses Flipper's built-in actor system
#   - Features auto-created on first enable
#
# Example in Flipper UI:
#   delivery (1 feature)
#     └── actors: ["Tenant;sample", "Tenant;twogate"]
#
class TenantFeatureFlags
  extend T::Sig

  class << self
    extend T::Sig

    # Check if a feature is enabled for the current tenant
    sig { params(flag_name: Symbol).returns(T::Boolean) }
    def enabled?(flag_name)
      tenant = Tenant.current
      return false if tenant.nil?

      Flipper.enabled?(flag_name, tenant)
    end

    # Enable feature for a specific tenant using Flipper actors
    sig { params(flag_name: Symbol, tenant: T.any(Tenant, String)).void }
    def enable(flag_name, tenant)
      tenant_obj = resolve_tenant(tenant)
      Flipper.enable(flag_name, tenant_obj)
    end

    # Disable feature for a specific tenant
    sig { params(flag_name: Symbol, tenant: T.any(Tenant, String)).void }
    def disable(flag_name, tenant)
      tenant_obj = resolve_tenant(tenant)
      Flipper.disable(flag_name, tenant_obj)
    end

    # Enable feature globally (all tenants via boolean gate)
    sig { params(flag_name: Symbol).void }
    def enable_globally(flag_name)
      Flipper.enable(flag_name)
    end

    # Disable feature globally (removes boolean gate, keeps actor gates)
    sig { params(flag_name: Symbol).void }
    def disable_globally(flag_name)
      Flipper.disable(flag_name)
    end

    # Remove feature entirely (removes all gates and actor settings)
    sig { params(flag_name: Symbol).void }
    def remove_feature(flag_name)
      Flipper.remove(flag_name)
    end

    # Check if a feature is enabled for a specific tenant (for admin UI)
    sig { params(flag_name: Symbol, tenant: T.any(Tenant, String)).returns(T::Boolean) }
    def enabled_for_tenant?(flag_name, tenant)
      tenant_obj = resolve_tenant(tenant)
      Flipper.enabled?(flag_name, tenant_obj)
    end

    # Check if global flag is enabled (boolean gate)
    sig { params(flag_name: Symbol).returns(T::Boolean) }
    def globally_enabled?(flag_name)
      feature = Flipper.feature(flag_name)
      feature.boolean_value
    end

    # List all tenants with feature enabled (via actor gates)
    sig { params(flag_name: Symbol).returns(T::Array[String]) }
    def enabled_tenants(flag_name)
      feature = Flipper.feature(flag_name)
      feature.actors_value
             .select { |actor_id| actor_id.start_with?('Tenant;') }
             .map { |actor_id| actor_id.delete_prefix('Tenant;') }
    end

    # Check if feature exists in Flipper
    sig { params(flag_name: Symbol).returns(T::Boolean) }
    def feature_exists?(flag_name)
      Flipper.features.map(&:key).include?(flag_name.to_s)
    end

    private

    # Resolve tenant from ID string or Tenant object
    sig { params(tenant: T.any(Tenant, String)).returns(Tenant) }
    def resolve_tenant(tenant)
      case tenant
      when Tenant
        tenant
      when String
        Tenant.find(tenant)
      end
    end
  end
end
