# typed: strict
# frozen_string_literal: true

module AdminArea
  class ApplicationController < ActionController::Base
    extend T::Sig
    include Pagy::Backend
    include AdminArea::ExceptionRescuable
    include FeatureFlaggable

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
  end
end
