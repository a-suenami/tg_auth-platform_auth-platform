# typed: true

module Users
  class SessionCreateService < BaseService
    def execute!(email:, password:)
      unless email =~ URI::MailTo::EMAIL_REGEXP
        raise Exceptions::Auth::AuthError
      end

      account_lock = AccountLock.check_lock!(email:)

      user = User.active.find_by(email:)
      T.must(account_lock).user_id = user.id if T.must(account_lock).user_id.blank? && user.present?
      if user&.authenticate!(password)
        T.must(account_lock).reset_failed_attempts
        user
      else
        T.must(account_lock).increment_failed_attempts
        raise Exceptions::Auth::AuthError
      end
    end
  end
end
