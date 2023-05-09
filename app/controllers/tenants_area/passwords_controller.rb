module TenantsArea
  class PasswordsController < ApplicationController
    def new
      @user = User.find session[:registering_user_id]
      return redirect_to '/profiles/new' if @user.password_digest.present?

      render "tenants_area/#{Tenant.current.id}_area/passwords/new"
    end

    def create
      @user = User.find session[:registering_user_id]
      return redirect_to '/profiles/new' if @user.password_digest.present?

      if @user.update(password_params)
        redirect_to '/profiles/new'
      else
        render "tenants_area/#{Tenant.current.id}_area/passwords/new"
      end
    end

    private

    def password_params
      params.require(:user).permit(:password, :password_confirmation)
    end
  end
end
