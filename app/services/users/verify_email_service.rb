# typed: false

module Users
  class VerifyEmailService < BaseService

    def execute(email_verification_code:, user_id:)
      user = User.find user_id

      if user.email_verification_code_remaining_attempts.positive?
        user.email_verification_code_remaining_attempts -= 1
        user.save

        if user.email_verification_code == email_verification_code
          if Time.zone.now < user.email_verification_code_expired_at
            user.email_verified = true
            user.save!
          else
            raise Exceptions::Auth::ExpiredEmailVerificationCode
          end
        else
          raise Exceptions::Auth::InvalidCode
        end
      else
        raise Exceptions::Auth::EmailVerificationCodeAttemptsIsOver
      end

      user
    end
  end
end
