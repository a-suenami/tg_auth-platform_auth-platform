module TenantsArea
  class PasswordsController < ApplicationController
    def new
      @user = User.find! session[:registering_user_id]
      render "tenants_area/#{Tenant.current.id}_area/passwords/new"
    end

    def create
    end
  end
end
