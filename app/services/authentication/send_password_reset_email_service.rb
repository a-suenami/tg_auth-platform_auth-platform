# typed: true

module Authentication
  class SendPasswordResetEmailService < BaseService

    def execute!(email:, base_url:)
      # email validate
      unless email =~ URI::MailTo::EMAIL_REGEXP
        raise Exceptions::Authentication::InvalidEmail
      end

      ActiveRecord::Base.transaction do
        user = User.active.find_by(email:, email_verified: true)
        if user.blank?
          # アカウントの存在を隠すため、エラーせずそのまま返す
          next true
        end

        password_reset = Users::PasswordReset.new(user:)
        password_reset.set_code
        password_reset.save!

        send_verification_email(user, password_reset, base_url)
        user
      end
    end

    def send_verification_email(user, password_reset, base_url)
      email_template = EmailTemplate.find_by!(template_type: 'password_reset')
      liquid_template = Liquid::Template.parse(email_template.body)

      # query encode
      params = {
        password_reset_code: password_reset.code,
      }.to_query
      password_reset_url = "#{base_url}?#{params}"

      Blastengine::API.new.send_email(
        send_to: user.email,
        subject: email_template.subject,
        body: liquid_template.render('password_reset_url' => password_reset_url),
        from_email: Tenant.current&.tenant_setting&.sender_email,
        from_name: Tenant.current&.name,
      )
    end
  end
end
