# typed: false

module Authentication
  class VerifySmsService < BaseService
    def execute!(verification_code:, user_id:)
      user = User.find user_id
      sms_verifier = Users::SmsVerifier.find_by(user:, code: verification_code, verifier_type: :registration, used_at: nil)

      if sms_verifier.blank?
        user.sms_verifiers.enabled.where(verifier_type: :registration).find_each do |ev|
          ev.remaining_attempts -= 1
          ev.save!
        end
        return raise Exceptions::Authentication::InvalidCode
      end

      if sms_verifier.remaining_attempts <= 0
        raise Exceptions::Authentication::SmsVerificationCodeAttemptsIsOver
      elsif Time.zone.now < sms_verifier.expired_at
        ActiveRecord::Base.transaction do
          user.sms_verified = true
          user.phone_number = sms_verifier.phone_number
          user.save!
          sms_verifier.used_at = Time.zone.now
          sms_verifier.save!
        end
      else
        raise Exceptions::Authentication::ExpiredEmailVerificationCode
      end

      user
    end
  end
end
