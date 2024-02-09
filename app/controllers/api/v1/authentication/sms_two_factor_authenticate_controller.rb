module API::V1::Authentication
  class SmsTwoFactorAuthenticateController < ApplicationController
    include CookieAuthable

    # send authentication sms
    def send_authentication_sms
      # マニュアル対応のユーザはもうSMS検証済みにしてしまう。
      if current_user.suppress_sms_verification
        cookie_session[:sms_two_factor_auth_verified] = Time.zone.now
        return render :send_authentication_sms
      end

      raise Exceptions::Authentication::UnregisteredVerifiedPhoneNumberError unless current_user.sms_verified && current_user.phone_number.present?
      # 必須でない場合一旦このAPIは無効。攻撃の対象に利用されないように。
      raise Exceptions::Authentication::SmsVerificationDisabled unless Tenant.current.sms_verification_required

      @user = Authentication::SendAuthenticationSmsService.new.execute!(
        phone_number: current_user.phone_number,
        user_id: current_user.id,
        ip_address: request.remote_ip,
        delivery_type: params[:delivery_type],
      )
      render :send_authentication_sms
    end

    # authenticate sms endpoint
    def authenticate_sms
      raise Exceptions::Authentication::UnregisteredVerifiedPhoneNumberError unless current_user.sms_verified && current_user.phone_number.present?
      # 必須でない場合一旦このAPIは無効。攻撃の対象に利用されないように。
      raise Exceptions::Authentication::SmsVerificationDisabled unless Tenant.current.sms_verification_required

      if Authentication::AuthenticateSmsService.new.execute!(verification_code: params[:sms_authentication_code], user_id: current_user.id)
        cookie_session[:sms_two_factor_auth_verified] = Time.zone.now
      end

      @user = current_user
      render :authenticate_sms
    end
  end
end
