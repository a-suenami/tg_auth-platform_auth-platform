# typed: true

module Authentication
  class SendAccountLockEmailService < BaseService
    def execute!(email:)
      # email validate
      unless email =~ URI::MailTo::EMAIL_REGEXP
        raise Exceptions::Authentication::InvalidEmail
      end

      ActiveRecord::Base.transaction do
        user = User.find_by(email:)

        send_account_lock_email(user)
        user
      end
    end

    def send_account_lock_email(user)
      email_template = EmailTemplate.find_by!(template_type: 'account_lock')
      liquid_template = Liquid::Template.parse(email_template.body)

      # query encode
      params = {
        unlock_token: user.account_lock.unlock_token,
      }.to_query
      unlock_url = "https://#{T.must(Tenant.current).domain}/account_locks/unlock?#{params}"

      Blastengine::API.new.send_email(
        send_to: user.email,
        subject: email_template.subject,
        body: liquid_template.render('unlock_url' => unlock_url),
        name: Tenant.current&.name,
      )
    end
  end
end
