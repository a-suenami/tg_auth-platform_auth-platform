# typed: true

module Users
  class SendEmailChangeEmailService < BaseService

    def execute!(user:, email:)
      # email validate
      unless email =~ URI::MailTo::EMAIL_REGEXP
        raise Exceptions::Users::InvalidEmail
      end

      ActiveRecord::Base.transaction do
        email_verifier = Users::EmailVerifier.new(user:, email:, email_verifier_type: :email_change)
        email_verifier.set_code
        email_verifier.save!
        user.save!

        send_verification_email(user, email_verifier)
        user
      end
    end

    def send_verification_email(user, email_verifier)
      email_template = EmailTemplate.find_by!(template_type: 'email_address_change')
      liquid_template = Liquid::Template.parse(email_template.body)

      Blastengine::API.new.send_email(
        send_to: user.email,
        subject: email_template.subject,
        body: liquid_template.render('email_verification_code' => email_verifier.code),
        name: Tenant.current&.name,
      )
    end
  end
end
