# typed: false

module Users
  class VerifyEmailService < BaseService

    def execute!(email_verification_code:, user_id:)
      user = User.find user_id
      email_verifier = Users::EmailVerifier.find_by(user: user, code: email_verification_code)

      return raise Exceptions::Services::Users::InvalidCode if email_verifier.blank?

      return raise Exceptions::Services::Users::EmailVerificationCodeAttemptsIsOver if email_verifier.remaining_attempts.positive?

      if email_verifier.code == email_verification_code
        if Time.zone.now < email_verifier.expired_at
          user.email_verified = true
          user.save!
          email_verifier.destroy!
        else
          raise Exceptions::Services::Users::ExpiredEmailVerificationCode
        end
      else
        email_verifier.remaining_attempts -= 1
        email_verifier.save
        raise Exceptions::Services::Users::InvalidCode
      end

      user
    end
  end
end
