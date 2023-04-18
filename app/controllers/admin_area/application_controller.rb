# frozen_string_literal: true

module AdminArea
  class ApplicationController < ActionController::Base
    include Pagy::Backend

    before_action :authenticate!
    before_action :set_tenant

    def authenticate!
      redirect_to admin_area_login_path unless signed_in?
    end

    def current_admin
      @current_admin ||= Admin.find_by(id: session[:current_admin_id])
    end

    def signed_in?
      current_admin.present?
    end

    def root
      flash[:alert] = 'this is an example message' # rubocop:disable Rails
      flash[:notice] = 'you can also use notice level flash' # rubocop:disable Rails
    end

    private
    def set_tenant
      RequestStore.store[:current_tenant_domain] = request.host || '-'
      Tenant.current
    end
  end
end
