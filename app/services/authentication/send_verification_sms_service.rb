# typed: true

module Authentication
  class SendVerificationSmsService < BaseService

    def execute!(local_phone_number:, phone_country_code:, user_id:)
      raise Exceptions::Authentication::PhoneNumberInvaild unless PhonyRails.plausible_number?(local_phone_number, country_number: phone_country_code)

      phone_number = PhonyRails.normalize_number(local_phone_number, country_number: phone_country_code)

      # 電話番号重複チェック
      raise Exceptions::Authentication::PhoneNumberDuplicated if User.find_by(phone_number:).present?

      ActiveRecord::Base.transaction do
        user = User.find user_id
        sms_verifier = Users::SmsVerifier.new(user:, phone_number:, verifier_type: :registration)
        sms_verifier.set_code
        sms_verifier.save!

        # TODO: 1ユーザが送信可能なsmsを制限orクールタイムを設ける。
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
  end
end
