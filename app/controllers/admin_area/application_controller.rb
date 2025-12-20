# typed: strict
# frozen_string_literal: true

module AdminArea
  class ApplicationController < ActionController::Base
    extend T::Sig
    include Pagy::Backend
    include AdminArea::ExceptionRescuable
    include FeatureFlaggable

    NEW_UI_FLAG = :admin_new_ui

    layout :resolve_layout
    helper_method :new_ui_enabled?

    before_action :authenticate!
    before_action :set_tenant

    sig { void }
    def authenticate!
      redirect_to admin_area_login_path unless signed_in?
    end

    sig { returns(T.nilable(Admin)) }
    def current_admin
      @current_admin ||= T.let(Admin.find_by(id: session[:current_admin_id]), T.nilable(Admin))
    end

    sig { returns(T::Boolean) }
    def signed_in?
      current_admin.present?
    end

    sig { void }
    def root
      flash[:alert] = 'this is an example message'
      flash[:notice] = 'you can also use notice level flash' # rubocop:disable Rails
    end

    private

    sig { returns(T.nilable(Tenant)) }
    def set_tenant
      # OPTIMIZE: Tenant.current で再度DBアクセスが走るので要最適化
      RequestStore.store[:current_tenant] = request.subdomain.split('.').first&.to_sym || '-'
      tenant = Tenant.find(RequestStore.store[:current_tenant])
      RequestStore.store[:current_tenant_domain] = tenant.domain

      Tenant.current
    end

    sig { returns(String) }
    def resolve_layout
      new_ui_enabled? ? 'admin_area/application_v202601' : 'admin_area/application'
    end

    sig { returns(T::Boolean) }
    def new_ui_enabled?
      feature_enabled?(NEW_UI_FLAG)
    end

    # Render the appropriate view based on feature flag
    # Usage: render_with_ui_toggle('index') or render_with_ui_toggle('show', locals: { user: @user })
    sig { params(action_name: String, options: T.untyped).void }
    def render_with_ui_toggle(action_name, **options)
      template = new_ui_enabled? ? "#{action_name}_v202601" : action_name
      render template, **options
    end
  end
end
