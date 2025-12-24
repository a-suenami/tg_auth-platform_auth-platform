# typed: strict
# frozen_string_literal: true

module UserArea
  class ApplicationController < ActionController::Base
    extend T::Sig
    include Pagy::Backend
    include ExpirableCookieUseable
    helper UserAreaHelper
    rescue_from Exception, with: :handle_500 if Rails.env.production?

    before_action :set_tenant
    before_action :load_design_settings

    helper_method :design_settings

    private

    sig { returns(T.nilable(Tenant)) }
    def set_tenant
      RequestStore.store[:current_tenant_domain] = request.host || '-'
      Tenant.current
    end

    sig { void }
    def load_design_settings
      @design_settings = T.let(Tenant.current&.design_setting || Tenant::DesignSetting.new, T.nilable(Tenant::DesignSetting))
    end

    sig { returns(Tenant::DesignSetting) }
    def design_settings
      T.must(@design_settings)
    end

    sig { params(exception: T.nilable(Exception)).void }
    def handle_500(exception = nil)
      Sentry.capture_exception(exception)
      logger.error("Rendering 500 with exception: #{exception.message}") if exception
      logger.error(exception.backtrace&.join("\n")) if exception

      # TODO: fix error page
      render 'user_area/sessions/error'
    end
  end
end
