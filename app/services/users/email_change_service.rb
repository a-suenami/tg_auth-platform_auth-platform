# typed: false

module Users
  class EmailChangeService < BaseService
    def execute!(user:, email_verification_code:)
      email_verifier = Users::EmailVerifier.find_by(user:, code: email_verification_code, email_verifier_type: :email_change, used_at: nil)

      if email_verifier.blank?
        user.email_verifiers.enabled.where(email_verifier_type: :email_change).each do |ev|
          ev.remaining_attempts -= 1
          ev.save!
        end
        return raise Exceptions::Services::Users::InvalidCode
      end

      return raise Exceptions::Services::Users::EmailVerificationCodeAttemptsIsOver if email_verifier.remaining_attempts <= 0

      if Time.zone.now < email_verifier.expired_at
        user.email = email_verifier.email
        user.email_verified = true
        user.save!
        email_verifier.used_at = Time.zone.now
        email_verifier.save!
      else
        raise Exceptions::Services::Users::ExpiredEmailVerificationCode
      end

      user
    end
  end
end
