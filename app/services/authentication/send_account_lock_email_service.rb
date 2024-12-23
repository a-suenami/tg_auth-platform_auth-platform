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
      # query encode
      params = {
        unlock_token: account_lock.unlock_token,
      }.to_query
      unlock_url = "https://#{T.must(Tenant.current).domain}/account_locks/unlock?#{params}"

      template_params = { unlock_url: }.transform_keys(&:to_s)

      User::SendEmailWorker.perform_async('account_lock', template_params, account_lock.email)
    end
  end
end
