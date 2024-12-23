# typed: true

module Authentication
  class SendVerificationEmailService < BaseService

    def execute!(email:, captcha_score: nil)
      # email validate
      unless email =~ URI::MailTo::EMAIL_REGEXP
        raise Exceptions::Authentication::InvalidEmail
      end

      # lower caseに変換
      email = email.downcase

      ActiveRecord::Base.transaction do
        user = User.active.find_or_create_by(email:)
        user.captcha_score = captcha_score
        user.save!
        email_verifier = Users::EmailVerifier.new(user:, email:, verifier_type: :registration)
        email_verifier.set_code
        email_verifier.save!

        send_verification_email(user, email_verifier)
        user
      end
    end

    def send_verification_email(user, email_verifier)
      template_params = { email_verification_code: email_verifier.code }.transform_keys(&:to_s)
      User::SendEmailWorker.perform_async(Tenant.current.id, 'email_address_verification', template_params, user.email)
    end
  end
end
