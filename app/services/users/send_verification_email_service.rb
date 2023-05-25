# typed: false

module Users
  class SendVerificationEmailService < BaseService

    def execute!(email:)
      # email validate
      unless email =~ URI::MailTo::EMAIL_REGEXP
        raise Exceptions::Services::Users::InvalidEmail
      end

      ActiveRecord::Base.transaction do
        user = User.find_by(email:, email_verified: true, enabled: true)
        if user.present?
          # アカウントの存在を隠すため、エラーせずそのまま返す
          next user
        end

        user = User.find_or_initialize_by(email:)
        user.set_email_verification_code
        user.save!

        send_verification_email(user)
        user
      end
    end

    def send_verification_email(user)
      email_template = EmailTemplate.find_by!(template_type: 'email_address_verification')
      liquid_template = Liquid::Template.parse(email_template.body)

      Blastengine::API.new.send_email(
        send_to: user.email,
        subject: email_template.subject,
        body: liquid_template.render('email_verification_code' => user.email_verification_code),
      )
    end
  end
end
