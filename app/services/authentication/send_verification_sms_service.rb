# typed: true

module Authentication
  class SendVerificationSmsService < BaseService

    def execute!(local_phone_number:, phone_country_code:, user_id:, ip_address:)
      raise Exceptions::Authentication::PhoneNumberInvaild unless PhonyRails.plausible_number?(local_phone_number, country_number: phone_country_code)

      phone_number = PhonyRails.normalize_number(local_phone_number, country_number: phone_country_code)
      user = User.find user_id

      # 電話番号重複チェック
      raise Exceptions::Authentication::PhoneNumberDuplicated if User.find_by(phone_number:).present?

      sms_rate_limit(phone_number:, user:, ip_address:)

      ActiveRecord::Base.transaction do
        sms_verifier = Users::SmsVerifier.new(user:, phone_number:, verifier_type: :registration, ip_address:)
        sms_verifier.set_code
        sms_verifier.save!

        send_verification_sms(sms_verifier)
        user
      end
    end

    def send_verification_sms(sms_verifier)
      # 国内電話番号はSmsLink、それ以外はTwilioを使う。
      if PhonyRails.country_code_from_number(sms_verifier.phone_number) == '81'
        response = SmsLink::API.new.send_sms(send_to: sms_verifier.japan_local_phone_number, body: "認証コードは#{sms_verifier.code}です。#{Tenant.current&.name}")
        sms_verifier.sms_sender = 'smslink'
        sms_verifier.sms_sid = response['delivery_id']
      else
        response = Twilio::API.new.send_sms(send_to: sms_verifier.phone_number, body: "認証コードは#{sms_verifier.code}です。#{Tenant.current&.name}")
        sms_verifier.sms_sender = 'twilio'
        sms_verifier.sms_sid = response.sid
      end
      sms_verifier.save
    end

    def sms_rate_limit(phone_number:, user:, ip_address:)
      # 開発環境,staging環境でratelimitが実装されていると検証が大変になるので無効化できるように
      return if Settings.sms.disable_rate_limit

      # 同一電話番号 5件/3hours
      raise Exceptions::Authentication::SmsSendLimit if Users::SmsVerifier.where('created_at > ?', 3.hours.ago).where(phone_number:).count >= 5
      # 同一電話番号 10件/24hours
      raise Exceptions::Authentication::SmsSendLimit if Users::SmsVerifier.where('created_at > ?', 24.hours.ago).where(phone_number:).count >= 10
      # 同一IP      100件/1hours
      raise Exceptions::Authentication::SmsSendLimit if Users::SmsVerifier.where('created_at > ?', 1.hour.ago).where(ip_address:).count >= 100
      # 同一ユーザ   10件/24hours
      raise Exceptions::Authentication::SmsSendLimit if Users::SmsVerifier.where('created_at > ?', 24.hours.ago).where(user:).count >= 10
    end
  end
end
