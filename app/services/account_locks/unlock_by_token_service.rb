# typed: strict

module AccountLocks
  class UnlockByTokenService < BaseService

    sig { params(token: T.nilable(String)).returns(T::Boolean) }
    def execute(token:)
      if token.present?
        account_lock = AccountLock.find_by(unlock_token: token)
        if account_lock.present?
          account_lock.reset_failed_attempts
          account_lock.save
          true
        else
          false
        end
      else
        false
      end
    end
  end
end
