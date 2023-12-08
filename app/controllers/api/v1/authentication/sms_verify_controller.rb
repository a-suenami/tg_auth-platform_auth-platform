module API::V1::Authentication
  class SmsVerifyController < ApplicationController
    before_action :registrations_session_authenticate, only: [:send_verification_sms, :verify_sms]

    # send verification sms
    def send_verification_sms
      raise Exceptions::Authentication::PhoneNumberAlreadySet if @current_user.sms_verified
      # 必須でない場合一旦このAPIは無効。攻撃の対象に利用されないように。
      raise Exceptions::Authentication::SmsVerificationDisabled unless Tenant.current.sms_verification_required

      @user = Authentication::SendVerificationSmsService.new.execute!(local_phone_number: params[:phone_number], phone_country_code: params[:phone_country_code], user_id: @current_user.id)
      render :send_verification_sms
    end

    # verify sms endpoint
    def verify_sms
      raise Exceptions::Authentication::PhoneNumberAlreadySet if @current_user.sms_verified
      # 必須でない場合一旦このAPIは無効。攻撃の対象に利用されないように。
      raise Exceptions::Authentication::SmsVerificationDisabled unless Tenant.current.sms_verification_required

      @user = Authentication::VerifySmsService.new.execute!(verification_code: params[:sms_verification_code], user_id: @current_user.id)

      render :verify_sms
    end

    private

    def registrations_session_authenticate
      raise Exceptions::Auth::AuthError if cookie_session[:registering_user_id].blank?

      @current_user = User.find cookie_session[:registering_user_id]
    end
  end
end
