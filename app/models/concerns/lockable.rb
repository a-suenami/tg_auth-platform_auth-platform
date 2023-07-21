# typed: strict

module Lockable
  extend ActiveSupport::Concern
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ApplicationRecord }

  sig { returns(T::Boolean) }
  def locked?
    return false if self.failed_attempts.nil?
    return false if self.failed_attempts.present? && T.must(self.failed_attempts) < Settings.account_lock.max_attempts

    if self.lock_expired_at && T.must(self.lock_expired_at) < Time.zone.now
      unlock!
      false
    else
      true
    end
  end

  sig { void }
  def increment_failed_attempts
    self.failed_attempts ||= 0

    self.failed_attempts = T.must(self.failed_attempts) + 1
    T.bind(self, ApplicationRecord)
    self.save
    T.bind(self, Lockable)
    if locked?
      lock!
    end
  end

  sig { returns(T::Boolean) }
  def reset_failed_attempts
    self.failed_attempts = 0
    T.bind(self, ApplicationRecord)
    self.save
  end

  sig { returns(T::Boolean) }
  def lock!
    self.unlock_token = SecureRandom.hex(32)
    self.lock_expired_at = Time.zone.now + Settings.account_lock.lockout_period_min&.minutes
    T.bind(self, ApplicationRecord)
    self.save!
  end

  sig { returns(T::Boolean) }
  def unlock!
    self.failed_attempts = 0
    self.unlock_token = nil
    self.lock_expired_at = nil
    T.bind(self, ApplicationRecord)
    self.save!
    self.reload
  end
end
