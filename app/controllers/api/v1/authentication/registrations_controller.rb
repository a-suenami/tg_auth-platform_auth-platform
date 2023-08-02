module API::V1::Authentication
  class RegistrationsController < ApplicationController
    # send email address verification email
    def send_verification_email
      @user = Users::SendVerificationEmailService.new.execute!(email: params[:email])
      render :send_verification_email
    end

    # verify email endpoint
    def verify_email
      @user = Users::VerifyEmailService.new.execute!(email_verification_code: params[:email_verification_code], user_id: params[:user_id])

      # 新規登録時のみ、仮登録セッションを作成する
      cookie_session[:registering_user_id] = @user.id if @user.enabled == false

      render :verify_email
    end
  end
end
