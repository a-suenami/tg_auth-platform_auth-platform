# typed: strict

class AccountLock < ApplicationRecord
  extend T::Sig
  include Multitenancy
  extend T::Helpers

  belongs_to :user, optional: true

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
    if self.last_failed_at && T.must(self.last_failed_at) < (Time.zone.now - Settings.account_lock.lockout_period_min&.minutes)
      self.failed_attempts = 0
    end

    self.failed_attempts += 1
    self.last_failed_at = Time.zone.now
    self.save
    if locked?
      lock!
    end
  end

  sig { returns(T::Boolean) }
  def reset_failed_attempts
    self.failed_attempts = 0
    self.unlock_token = nil
    self.lock_expired_at = nil
    self.save
  end

  sig { returns(T::Boolean) }
  def lock!
    if unlock_token.blank?
      self.unlock_token = SecureRandom.hex(32)
      self.lock_expired_at = Time.zone.now + Settings.account_lock.lockout_period_min&.minutes
      self.save!
      if self.user.present?
        Users::SendAccountLockEmailService.new.execute!(email: self.email)
      end
    end
    self.save!
  end

  sig { returns(AccountLock) }
  def unlock!
    self.failed_attempts = 0
    self.unlock_token = nil
    self.lock_expired_at = nil
    self.save!
    self.reload
  end
end
