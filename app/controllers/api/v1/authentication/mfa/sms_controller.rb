module API::V1::Authentication::MFA
  class SmsController < API::V1::Authentication::ApplicationController
    include CookieAuthable

    # send authentication sms
    def send_sms
      # マニュアル対応のユーザはもうSMS検証済みにしてしまう。
      if current_user.suppress_sms_verification
        @user = current_user
        return render :send
      end

      raise Exceptions::Authentication::UnregisteredVerifiedPhoneNumberError unless current_user.sms_verified && current_user.phone_number.present?
      # 必須でない場合一旦このAPIは無効。攻撃の対象に利用されないように。
      raise Exceptions::Authentication::SmsVerificationDisabled unless Tenant.current.sms_verification_required

      @user = Authentication::SendVerificationSmsService.new.execute!(
        phone_number: current_user.phone_number,
        user_id: current_user.id,
        ip_address: request.remote_ip,
        delivery_type: params[:delivery_type],
        verifier_type: :mfa,
      )
      render :send
    end

    # authenticate sms endpoint
    def authenticate
      raise Exceptions::Authentication::UnregisteredVerifiedPhoneNumberError unless current_user.sms_verified && current_user.phone_number.present?
      # 必須でない場合一旦このAPIは無効。攻撃の対象に利用されないように。
      raise Exceptions::Authentication::SmsVerificationDisabled unless Tenant.current.sms_verification_required

      if Authentication::VerifySmsService.new.execute!(verification_code: params[:code], user_id: current_user.id, verifier_type: :mfa)
        cookie_session[:sms_mfa_verified] = Time.zone.now
      end

      @user = current_user
      render :authenticate
    end
  end
end
