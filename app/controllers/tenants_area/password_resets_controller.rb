module TenantsArea
  class PasswordResetsController < ApplicationController
    def new
      render "tenants_area/#{Tenant.current.id}_area/password_resets/new"
    end

    def edit
      @password_reset_code = params[:password_reset_code]
      @email = params[:email]
      render "tenants_area/#{Tenant.current.id}_area/password_resets/edit"
    end

    def create
      Users::SendPasswordResetEmailService.new.execute!(email: params[:email], base_url: "#{request.protocol}#{request.host_with_port}/password_resets/edit")
      render "tenants_area/#{Tenant.current.id}_area/password_resets/sent_email"
    rescue Exceptions::Services::Users::BaseError => e
      flash[:alert] = e.message
      @user = User.new
      render "tenants_area/#{Tenant.current.id}_area/password_resets/new"
    end


    def update
      Users::PasswordResetService.new(update_password_params).execute!(password_reset_code: params[:password_reset_code], email: params[:email])
      redirect_to new_session_path
    rescue Exceptions::Services::Users::BaseError => e
      flash[:alert] = e.message
      @password_reset_code = params[:password_reset_code]
      @email = params[:email]
      render "tenants_area/#{Tenant.current.id}_area/password_resets/edit"
    end

    private

    def update_password_params
      params.permit(:password, :password_confirmation)
    end
  end
end
