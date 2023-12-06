# typed: true

module Users
  class SendVerificationSmsService < BaseService

    def execute!(phone_number:, phone_country_code:, user_id:)
      # TODO: tel validate
      # unless email =~ URI::MailTo::EMAIL_REGEXP
      #   raise Exceptions::Services::Users::InvalidEmail
      # end

      ActiveRecord::Base.transaction do
        user = User.find user_id
        sms_verifier = Users::SmsVerifier.new(user:, phone_number:, phone_country_code:, verifier_type: :registration)
        sms_verifier.set_code
        sms_verifier.save!

        send_verification_sms(user, sms_verifier)
        user
      end
    end

    def send_verification_sms(user, sms_verifier)
      # 国内電話番号はSmsLink、それ以外はTwilioを使う。
      if sms_verifier.phone_country_code == '81'
        response = SmsLink::API.new.send_sms(send_to: sms_verifier.phone_number, body: "認証コードは#{sms_verifier.code}です。#{Tenant.current.name}")
        # 一応ログとして出力
        Rails.logger.info(response)
      else
        # TODO:
      end
    end
  end
end
