# typed: false

module Users
  class VerifyEmailService < BaseService

    def execute!(email_verification_code:, user_id:)
      user = User.find user_id

      if user.email_verification_code_remaining_attempts.positive?
        user.email_verification_code_remaining_attempts -= 1
        user.save

        if user.email_verification_code == email_verification_code
          if Time.zone.now < user.email_verification_code_expired_at
            user.email_verification_code = nil
            user.email_verification_code_expired_at = nil
            user.email_verified = true
            user.save!
          else
            raise Exceptions::Services::Users::ExpiredEmailVerificationCode
          end
        else
          raise Exceptions::Services::Users::InvalidCode
        end
      else
        raise Exceptions::Services::Users::EmailVerificationCodeAttemptsIsOver
      end

      user
    end
  end
end
