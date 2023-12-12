# typed: false

module Users
  class EmailChangeService < BaseService
    def execute!(user:, email_verification_code:)
      email_verifier = Users::EmailVerifier.find_by(user:, code: email_verification_code, verifier_type: :email_change, used_at: nil)

      if email_verifier.blank?
        user.email_verifiers.enabled.where(verifier_type: :email_change).find_each do |ev|
          ev.remaining_attempts -= 1
          ev.save!
        end
        return raise Exceptions::Users::InvalidCode
      end

      return raise Exceptions::Users::EmailVerificationCodeAttemptsIsOver if email_verifier.remaining_attempts <= 0

      if Time.zone.now < email_verifier.expired_at
        user.email = email_verifier.email
        user.email_verified = true
        user.save!
        email_verifier.used_at = Time.zone.now
        email_verifier.save!
        # アカウントロックはemailを元にカウントするので、email変更時削除
        if user.account_lock.present?
          user.account_lock.destroy
        end
      else
        raise Exceptions::Users::ExpiredEmailVerificationCode
      end

      # aws event bridgeにイベント発行
      PublishEvents::PublishService.new.execute(user:, action_code: :update)

      user
    end
  end
end
