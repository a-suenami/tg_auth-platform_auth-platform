module API::V1::Authentication
  class RegistrationsController < ApplicationController
    include SessionKeyUseable
    # send email address verification email
    def send_verification_email
      @user = Users::SendVerificationEmailService.new.execute!(email: params[:email])
      render :send_verification_email
    end

    # verify email endpoint
    def verify_email
      @user = Users::VerifyEmailService.new.execute!(email_verification_code: params[:email_verification_code], user_id: params[:user_id])

      @session_key = init_session_key(@user.id)

      render :verify_email
    end
  end
end
