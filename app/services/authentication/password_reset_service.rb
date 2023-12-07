# typed: false

module Authentication
  class PasswordResetService < BaseService

    def execute!(email:, password_reset_code:)
      # email validate
      unless email =~ URI::MailTo::EMAIL_REGEXP
        raise Exceptions::Services::Authentication::InvalidEmail
      end

      ActiveRecord::Base.transaction do
        user = User.find_by(email:, email_verified: true)
        password_reset = Users::PasswordReset.find_by(user:, code: password_reset_code, expired_at: Time.zone.now..)
        if user.blank? || password_reset.blank?
          # アカウントの存在を隠すため、ユーザが存在しない場合もPasswordResetCodeInvalidエラー
          raise Exceptions::Services::Authentication::PasswordResetCodeInvalid
        elsif password_reset.expired_at < Time.zone.now
          raise Exceptions::Services::Authentication::PasswordResetCodeExpired
        elsif password_reset.used_at.present?
          raise Exceptions::Services::Authentication::PasswordResetCodeUsed
        else
          user.update!(params)
          password_reset.update!(used_at: Time.zone.now)
        end

        # パスワード変更時アカウントロックがある場合解除
        if user.account_lock.present?
          user.account_lock.unlock!
        end

        user
      end
    end
  end
end
