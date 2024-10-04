# typed: true

module Authentication
  class SessionCreateService < BaseService
    def execute!(email:, password:)
      unless email =~ URI::MailTo::EMAIL_REGEXP
        raise Exceptions::Auth::AuthError
      end

      account_lock = AccountLock.check_lock!(email: email.downcase)

      user = find_active_user(email:)

      if user&.authenticate!(password)
        T.must(account_lock).reset_failed_attempts
        user
      else
        T.must(account_lock).increment_failed_attempts
        raise Exceptions::Auth::AuthError
      end
    end

    def find_active_user(email:)
      # emailそのまま + email.downcaseでユーザを検索する
      user = User.active.find_by(email:)
      user = User.active.find_by(email: email.downcase) if user.nil?
      user
    end
  end
end
