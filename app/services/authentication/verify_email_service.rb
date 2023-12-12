# typed: false

module Authentication
  class VerifyEmailService < BaseService
    def execute!(email_verification_code:, user_id:)
      user = User.find user_id
      email_verifier = Users::EmailVerifier.find_by(user:, code: email_verification_code, verifier_type: :registration, used_at: nil)

      if email_verifier.blank?
        user.email_verifiers.enabled.where(verifier_type: :registration).find_each do |ev|
          ev.remaining_attempts -= 1
          ev.save!
        end
        return raise Exceptions::Authentication::InvalidCode
      end

      if email_verifier.remaining_attempts <= 0
        raise Exceptions::Authentication::EmailVerificationCodeAttemptsIsOver
      elsif Time.zone.now < email_verifier.expired_at
        user.email_verified = true
        user.save!
        email_verifier.used_at = Time.zone.now
        email_verifier.save!
      else
        raise Exceptions::Authentication::ExpiredEmailVerificationCode
      end

      user
    end
  end
end
