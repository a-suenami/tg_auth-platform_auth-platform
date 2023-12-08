# typed: strict

module Users
  class EmailVerifier < ApplicationRecord
    extend T::Sig
    include Multitenancy
    CODE_ATTEMPTS_LIMIT = T.let(5, Integer)

    belongs_to :user
    enumerize :verifier_type, in: [:registration, :email_change]

    scope :enabled, -> { where(expired_at: Time.zone.now.., used_at: nil).where.not(remaining_attempts: 0) }

    sig { returns(T::Boolean) }
    def set_code
      self.code = format('%06d', SecureRandom.random_number(10**6))
      self.expired_at = 1.hour.from_now
      self.remaining_attempts = CODE_ATTEMPTS_LIMIT
      true
    end
  end
end
