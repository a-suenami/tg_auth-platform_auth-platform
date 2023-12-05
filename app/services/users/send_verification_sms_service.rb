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
      # TODO: sms送信
    end
  end
end
