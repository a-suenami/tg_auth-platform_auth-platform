# typed: true

module Authentication
  class SendAccountLockEmailService < BaseService
    def execute!(email:)
      # email validate
      unless email =~ URI::MailTo::EMAIL_REGEXP
        raise Exceptions::Authentication::InvalidEmail
      end

      ActiveRecord::Base.transaction do
        user = User.active.find_by(email:)
        account_lock = AccountLock.find_by(email:)

        # 有効なユーザが存在している場合にのみメールを送信
        if user.present? && account_lock.present?
          send_account_lock_email(account_lock)
        end
        user
      end
    end

    def send_account_lock_email(account_lock)
      email_template = EmailTemplate.find_by!(template_type: 'account_lock')
      liquid_template = Liquid::Template.parse(email_template.body)

      # query encode
      params = {
        unlock_token: account_lock.unlock_token,
      }.to_query
      unlock_url = "https://#{T.must(Tenant.current).domain}/account_locks/unlock?#{params}"

      Blastengine::API.new.send_email(
        send_to: account_lock.email,
        subject: email_template.subject,
        body: liquid_template.render('unlock_url' => unlock_url),
        from_email: Tenant.current&.tenant_setting&.sender_email,
        from_name: Tenant.current&.name,
      )
    end
  end
end
