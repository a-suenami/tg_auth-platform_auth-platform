# typed: strict

module Authentication
  class PasswordResetService < BaseService

    sig { params(password_reset_code: String).returns(User) }
    def execute!(password_reset_code:)
      ActiveRecord::Base.transaction do
        password_reset = Users::PasswordReset.find_by(code: password_reset_code, expired_at: Time.zone.now..)
        if password_reset.blank?
          raise Exceptions::Authentication::PasswordResetCodeInvalid
        elsif password_reset.expired_at < Time.zone.now
          raise Exceptions::Authentication::PasswordResetCodeExpired
        elsif password_reset.used_at.present?
          raise Exceptions::Authentication::PasswordResetCodeUsed
        else
          T.must(password_reset.user).update!(params)
          password_reset.update!(used_at: Time.zone.now)
        end

        # パスワード変更時アカウントロックがある場合解除
        if password_reset.user&.email.present?
          account_lock = AccountLock.find_by(email: T.must(password_reset.user).email)
          if account_lock.present?
            account_lock.unlock!
          end
        end

        password_reset.user
      end
    end
  end
end
