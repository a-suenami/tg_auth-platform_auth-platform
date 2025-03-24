# typed: strict

module Users
  class EmailChangeService < BaseService
    sig { params(user: User, email_verification_code: String).returns(User) }
    def execute!(user:, email_verification_code:)
      email_verifier = Users::EmailVerifier.find_by(user:, code: email_verification_code, verifier_type: :email_change, used_at: nil)

      if email_verifier.blank?
        user.email_verifiers.enabled.where(verifier_type: :email_change).find_each do |ev|
          ev.remaining_attempts = T.must(ev.remaining_attempts) - 1
          ev.save!
        end
        raise Exceptions::Users::InvalidCode
      end

      raise Exceptions::Users::EmailVerificationCodeAttemptsIsOver if T.must(email_verifier.remaining_attempts) <= 0

      if Time.zone.now < email_verifier.expired_at
        user.email = email_verifier.email
        user.email_verified = true
        user.save!
        email_verifier.used_at = Time.zone.now
        email_verifier.save!
      else
        raise Exceptions::Users::ExpiredEmailVerificationCode
      end

      # aws event bridgeにイベント発行
      PublishEvents::PublishService.new.execute(user:, action_code: :update)

      user
    end
  end
end
