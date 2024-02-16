# typed: strict

module Authentication
  class VerifySmsService < BaseService
    extend T::Sig

    sig { params(verification_code: String, user_id: String, verifier_type: Symbol).returns(User) }
    def execute!(verification_code:, user_id:, verifier_type: :registration)
      user = User.active.find user_id
      sms_verifier = Users::SmsVerifier.find_by(user:, code: verification_code, verifier_type:, used_at: nil)

      if !Rails.env.production? && Settings.super_mode == true # SUPER_MODE では常に成功
        user.sms_verified = true
        user.phone_number = "+81#{rand(7..9)}0#{rand(70_000_000..90_000_000)}"
        user.save!(validate: false)
        return user
      end

      if sms_verifier.blank?
        user.sms_verifiers.enabled.where(verifier_type:).find_each do |ev|
          ev.remaining_attempts -= 1
          ev.save!
        end
        raise Exceptions::Authentication::InvalidCode
      end

      if T.must(sms_verifier.remaining_attempts) <= 0
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
