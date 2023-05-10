module TenantsArea
  class RegistrationsController < ApplicationController
    # email form
    def new
      @user = User.new
      render registrations_new_path
    end

    # send email address verification email
    def send_verification_email
      base_url = "https://#{Tenant.current.domain}/registrations/email_verification"
      @user = Users::SendVerificationEmailService.new.execute(email: send_verification_email_params[:email], base_url:)
      if @user.present?
        render "tenants_area/#{Tenant.current.id}_area/registrations/send_verification_email"
      else
        @user = User.new
        render registrations_new_path
      end
    rescue Exceptions::Auth::InvalidEmail
      flash[:alert] = 'Invalid email'
      @user = User.new
      render registrations_new_path
    end

    # email verification endpoint
    def email_verification
      @user = Users::EmailVerificationService.new.execute(email_confirm_code: params[:email_confirm_code], user_id: params[:user_id])
      if @user.present?
        redirect_to '/passwords/new'
        session[:registering_user_id] = @user.id
      else
        @user = User.new
        render registrations_new_path
      end
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
