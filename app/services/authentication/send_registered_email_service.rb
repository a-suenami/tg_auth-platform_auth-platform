# typed: true

module Authentication
  class SendRegisteredEmailService < BaseService
    def execute!(user:)
      ActiveRecord::Base.transaction do
        send_registered_email(user)
      end
    end

    def send_registered_email(user)
      email_template = EmailTemplate.find_by!(template_type: 'registered')
      liquid_template = Liquid::Template.parse(email_template.body)

      Blastengine::API.new.send_email(
        send_to: user.email,
        subject: email_template.subject,
        body: liquid_template.render('email' => user.email),
        from_email: Tenant.current&.tenant_setting&.sender_email,
        from_name: Tenant.current&.name,
      )
    end
  end
end
