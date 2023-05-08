# typed: false

module Users
  class SendVerificationEmailService < BaseService

    def execute(email:, base_url:)
      # email validate
      unless email =~ URI::MailTo::EMAIL_REGEXP
        raise Exceptions::API::ServerError.new(status: '400', body: 'invalid email')
      end

      ActiveRecord::Base.transaction do
        user = User.find_by(email:, email_verified: true)
        if user.present?
          raise Exceptions::API::ServerError.new(status: '400', body: 'already registered')
        end

        user = User.find_or_initialize_by(email:)
        user.set_email_confirm_code
        user.save!

        send_verification_email(user, base_url)
        user
      end
    end

    def send_verification_email(user, base_url)
      email_template = EmailTemplate.find_by!(template_type: 'email_address_verification')
      liquid_template = Liquid::Template.parse(email_template.body)

      email_verification_url = "#{base_url}?email_confirm_code=#{user.email_confirm_code}&user_id=#{user.id}"
      Blastengine::API.new.send_email(
        send_to: user.email,
        subject: email_template.subject,
        body: liquid_template.render('email_verification_url' => email_verification_url),
      )
    end
  end
end
