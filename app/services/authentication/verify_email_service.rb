# typed: strict

module Authentication
  class VerifyEmailService < BaseService
    extend T::Sig

    sig { params(email_verification_code: String, user_id: String).returns(User) }
    def execute!(email_verification_code:, user_id:)
      user = User.active.find user_id
      email_verifier = Users::EmailVerifier.find_by(user:, code: email_verification_code, verifier_type: :registration, used_at: nil)

      if email_verifier.blank?
        user.email_verifiers.enabled.where(verifier_type: :registration).find_each do |ev|
          ev.remaining_attempts -= 1
          ev.save!
        end
        raise Exceptions::Authentication::InvalidCode
      end

      if !Rails.env.production? && Settings.super_mode == true # SUPER_MODE では常に成功
        user.email_verified = true
        user.save!
        email_verifier.used_at = Time.zone.now
        email_verifier.save!
        return user
      end

      if T.must(email_verifier.remaining_attempts) <= 0
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
