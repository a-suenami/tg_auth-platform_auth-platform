# typed: true
# frozen_string_literal: true

module API::V1::Public
  class TenantStripeAccountsController < API::ApplicationController
    def show
      tenant = Tenant.current!
      tenant_stripe_account = tenant.tenant_stripe_account
      raise ActiveRecord::RecordNotFound if tenant_stripe_account.nil?

      render_blueprint(Tenant::StripeAccountBlueprint, tenant_stripe_account)
    end
  end
end
