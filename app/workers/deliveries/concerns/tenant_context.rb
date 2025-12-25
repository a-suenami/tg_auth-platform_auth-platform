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

        # Set Sentry context for debugging
        Sentry.set_tags(tenant_id: tenant_id, tenant_domain: tenant.domain)

        Tenant.current
      end

      # Capture a soft failure (error that doesn't raise exception) to Sentry
      # @param message [String] Error description
      # @param context [Hash] Additional context (record_id, type, api_response, etc.)
      # @param level [Symbol] :error, :warning, :info (default: :error)
      def capture_soft_failure(message, context: {}, level: :error)
        Sentry.capture_message(
          message,
          level: level,
          extra: context,
          tags: { soft_failure: true },
        )
      end
    end
  end
end
