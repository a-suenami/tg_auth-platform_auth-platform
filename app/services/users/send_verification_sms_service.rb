# typed: true

module Users
  class SendVerificationSmsService < BaseService

    def execute!(phone_number:, phone_country_code:, user_id:)
      # TODO: phone number validate

      # 電話番号重複チェック
      raise Exceptions::Services::Users::PhoneNumberDuplicated if User.find_by(phone_number:, phone_country_code:).present?

      ActiveRecord::Base.transaction do
        user = User.find user_id
        sms_verifier = Users::SmsVerifier.new(user:, phone_number:, phone_country_code:, verifier_type: :registration)
        sms_verifier.set_code
        sms_verifier.save!

        # TODO: 1ユーザが送信可能なsmsを制限orクールタイムを設ける。
        send_verification_sms(sms_verifier)
        user
      end
    end

    def send_verification_sms(sms_verifier)
      # 国内電話番号はSmsLink、それ以外はTwilioを使う。
      if sms_verifier.phone_country_code == '81'
        response = SmsLink::API.new.send_sms(send_to: sms_verifier.phone_number, body: "認証コードは#{sms_verifier.code}です。#{Tenant.current.name}")
        # 一応ログとして出力
        Rails.logger.info(response)
      end
      # TODO: 海外電話番号対応
    end
  end
end
