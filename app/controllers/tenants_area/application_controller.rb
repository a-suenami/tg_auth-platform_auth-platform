# frozen_string_literal: true

module TenantsArea
  class ApplicationController < ActionController::Base
    include Pagy::Backend
    rescue_from Exception, with: :handle_500 if Rails.env.production?

    before_action :set_tenant

    private

    def set_tenant
      RequestStore.store[:current_tenant_domain] = request.host || '-'
      Tenant.current
    end

    def handle_500(exception = nil)
      # Raven.user_context(user_id: current_user&.id) if try(:current_user)
      # Raven.capture_exception(exception)
      logger.error("Rendering 500 with exception: #{exception.message}") if exception
      logger.error(exception.backtrace.join("\n")) if exception

      # TODO: fix error page
      render "tenants_area/#{Tenant.current.id}_area/sessions/error"
    end
  end
end
