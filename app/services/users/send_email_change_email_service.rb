# typed: true

module Users
  class SendEmailChangeEmailService < BaseService

    def execute!(user:, email:)
      # email validate
      unless email =~ URI::MailTo::EMAIL_REGEXP
        raise Exceptions::Users::InvalidEmail
      end

      # lower caseに変換
      email = email.downcase

      ActiveRecord::Base.transaction do
        email_verifier = Users::EmailVerifier.new(user:, email:, verifier_type: :email_change)
        email_verifier.set_code
        email_verifier.save!
        user.save!

        send_verification_email(email_verifier)
        user
      end
    end

    def send_verification_email(email_verifier)
      template_params = { email_verification_code: email_verifier.code }.transform_keys(&:to_s)
      User::SendEmailWorker.perform_async(Tenant.current.id, 'email_address_change', template_params, email_verifier.email)
    end
  end
end
