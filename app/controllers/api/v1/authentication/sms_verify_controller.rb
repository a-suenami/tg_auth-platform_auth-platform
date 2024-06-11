module API::V1::Authentication
  class SmsVerifyController < ApplicationController
    include CookieAuthable

    # send verification sms
    def send_verification_sms
      raise Exceptions::Authentication::PhoneNumberAlreadySet if @current_user.sms_verified
      # 必須でない場合一旦このAPIは無効。攻撃の対象に利用されないように。
      raise Exceptions::Authentication::SmsVerificationDisabled unless Tenant.current.sms_verification_required

      phone_number = international_phone_number(params[:phone_number], params[:phone_country_code])
      # 電話番号重複チェック
      raise Exceptions::Authentication::PhoneNumberDuplicated if User.active.find_by(phone_number:).present?

      @user = Authentication::SendVerificationSmsService.new.execute!(
        phone_number:,
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

      # SMS検証が成功した場合はセッションに記録
      if @user.sms_verified
        cookie_session[:sms_mfa_verified] = Time.zone.now
      end

      render :verify_sms
    end

    private

    def international_phone_number(local_phone_number, phone_country_code)
      raise Exceptions::Authentication::PhoneNumberInvaild unless PhonyRails.plausible_number?(local_phone_number, country_number: phone_country_code)

      phone_number = PhonyRails.normalize_number(local_phone_number, country_number: phone_country_code)
      # Phonelibの方が市外局番以降まで厳密にチェックしてくれるので、2重でチェック
      # TODO: 国コードではなく国名コードを受け付けるようにすればPhonyRailsは不要
      raise Exceptions::Authentication::PhoneNumberStrictlyInvaild unless Phonelib.valid?(phone_number)

      phone_number
    end
  end
end
