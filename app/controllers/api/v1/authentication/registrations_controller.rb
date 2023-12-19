module API::V1::Authentication
  class RegistrationsController < ApplicationController
    # send email address verification email
    def send_verification_email
      # google_cloud_service_accountが設定されている場合のみ、reCAPTCHAのスコアを取得する
      captcha_score = if Tenant.current.tenant_setting&.google_cloud_service_account.present?
        captcha_token = T.cast(params[:captcha_token], String)
        captcha_integration = RecaptchaEnterpriseUtils::Integration.deserialize(params[:captcha_type] || 'checkbox')

        raise Exceptions::Auth::RecaptchaTokenInvaild if captcha_token.blank?

        assessment = RecaptchaEnterpriseUtils.new(tenant: T.must(Tenant.current), token: captcha_token, integration: captcha_integration).assess

        unless assessment.valid
          error = T.must(assessment.error)
          return authentication_error(message: error.message, code: error.code)
        end

        assessment.score
      end

      @user = Authentication::SendVerificationEmailService.new.execute!(email: params[:email], captcha_score:)
      render :send_verification_email
    end

    # verify email endpoint
    def verify_email
      @user = Authentication::VerifyEmailService.new.execute!(email_verification_code: params[:email_verification_code], user_id: params[:user_id])

      # 新規登録時のみ、仮登録セッションを作成する
      cookie_session[:registering_user_id] = @user.id if @user.enabled == false

      # 旧domainのクッキーがある場合削除
      Authentication::DeleteOldSessionService.new.execute(request:)

      render :verify_email
    end
  end
end
