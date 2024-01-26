module API::V1::Authentication
  class SmsVerifyController < ApplicationController
    include CookieAuthable

    # send verification sms
    def send_verification_sms
      raise Exceptions::Authentication::PhoneNumberAlreadySet if @current_user.sms_verified
      # 必須でない場合一旦このAPIは無効。攻撃の対象に利用されないように。
      raise Exceptions::Authentication::SmsVerificationDisabled unless Tenant.current.sms_verification_required

      @user = Authentication::SendVerificationSmsService.new.execute!(
        local_phone_number: params[:phone_number],
        phone_country_code: params[:phone_country_code],
        user_id: @current_user.id,
        ip_address: request.remote_ip,
        delivery_type: params[:delivery_type],
      )
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
  end
end
