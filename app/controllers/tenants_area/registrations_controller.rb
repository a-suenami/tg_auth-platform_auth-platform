module TenantsArea
  class RegistrationsController < ApplicationController
    # email form
    def new
      @user = User.new
      render registrations_new_path
    end

    # send email address verification email
    def send_verification_email
      @user = Users::SendVerificationEmailService.new.execute!(email: send_verification_email_params[:email])
      session[:registering_user_id] = @user.id
      render "tenants_area/#{Tenant.current.id}_area/registrations/send_verification_email"
    rescue Exceptions::Services::Users::BaseError => e
      flash[:alert] = e.message
      @user = User.new
      render registrations_new_path
    end

    # verify email endpoint
    def verify_email
      @user = Users::VerifyEmailService.new.execute!(email_verification_code: params[:email_verification_code], user_id: session[:registering_user_id])
      redirect_to '/passwords/new'
    rescue Exceptions::Services::Users::InvalidCode => e
      flash[:alert] = e.message
      @user = User.find session[:registering_user_id]
      render "tenants_area/#{Tenant.current.id}_area/registrations/send_verification_email"
    rescue Exceptions::Services::Users::BaseError => e
      flash[:alert] = e.message
      @user = User.new
      render registrations_new_path
    end

    private

    def send_verification_email_params
      params.require(:user).permit(:email)
    end

    def registrations_new_path
      "tenants_area/#{Tenant.current.id}_area/registrations/new"
    end
  end
end
