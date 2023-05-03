# typed: false

module Users
  class CreateService < BaseService

    def execute
      ActiveRecord::Base.transaction do
        user = User.new(params)
        user.set_email_confirm_code

        user.save

        send_registration_email(user)
        user
      end
    end

    def send_registration_email(user)
      email_template = EmailTemplate.find_by!(template_type: 'registration')
      liquid_template = Liquid::Template.parse(email_template.body)

      Blastengine::API.new.send_email(
        send_to: user.email,
        subject: email_template.subject,
        body: liquid_template.render('email' => user.email),
      )
    end
  end
end
