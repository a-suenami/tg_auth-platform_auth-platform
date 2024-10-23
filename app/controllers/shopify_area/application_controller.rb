# frozen_string_literal: true

module ShopifyArea
  class ApplicationController < ActionController::Base
    include Pagy::Backend
    include ExpirableCookieUseable
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
      render 'shopify_area/sessions/error'
    end
  end
end
