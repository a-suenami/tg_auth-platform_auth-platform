# typed: strict

class AccountLock < ApplicationRecord
  extend T::Sig
  include Multitenancy
  extend T::Helpers

  sig { params(email: String).returns(T.nilable(AccountLock)) }
  def self.check_lock!(email:)
    account_lock = AccountLock.find_or_initialize_by(email:)
    if account_lock.locked?
      raise Exceptions::Auth::AccountLocked
    else
      account_lock
    end
  end

  sig { returns(T::Boolean) }
  def locked?
    return false if self.failed_attempts.nil?
    return false if self.failed_attempts.present? && self.failed_attempts < Settings.account_lock.max_attempts

    if self.lock_expired_at && T.must(self.lock_expired_at) < Time.zone.now
      self.unlock!
      false
    else
      true
    end
  end

  sig { void }
  def increment_failed_attempts
    self.failed_attempts += 1
    self.save
    if locked?
      lock!
    end
  end

  sig { returns(T::Boolean) }
  def reset_failed_attempts
    self.failed_attempts = 0
    self.save
  end

  sig { returns(T::Boolean) }
  def lock!
    self.unlock_token = SecureRandom.hex(32)
    self.lock_expired_at = Time.zone.now + Settings.account_lock.lockout_period_min&.minutes
    self.save!
  end

  sig { returns(T::Boolean) }
  def unlock!
    self.failed_attempts = 0
    self.unlock_token = nil
    self.lock_expired_at = nil
    self.save!
    self.reload
  end
end
