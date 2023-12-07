# typed: false

module Authentication
  class VerifyEmailService < BaseService
    def execute!(email_verification_code:, user_id:)
      user = User.find user_id
      email_verifier = Users::EmailVerifier.find_by(user:, code: email_verification_code, email_verifier_type: :registration, used_at: nil)

      if email_verifier.blank?
        user.email_verifiers.enabled.where(email_verifier_type: :registration).each do |ev|
          ev.remaining_attempts -= 1
          ev.save!
        end
        return raise Exceptions::Services::Authentication::InvalidCode
      end

      if email_verifier.remaining_attempts <= 0
        raise Exceptions::Services::Authentication::EmailVerificationCodeAttemptsIsOver
      elsif Time.zone.now < email_verifier.expired_at
        user.email_verified = true
        user.save!
        email_verifier.used_at = Time.zone.now
        email_verifier.save!
      else
        raise Exceptions::Services::Authentication::ExpiredEmailVerificationCode
      end

      user
    end
  end
end
