# typed: false

# ==============================================================================
# app - models - app stripe
# ==============================================================================
class AppStripe
  def self.configuration
    current_domain ||= RequestStore.store[:current_tenant_domain]
    return {} if current_domain.blank?

    { api_key: Tenant.current&.tenant_stripe_account&.stripe_account&.api_key&.secret_key }
  end
end
