# typed: strict

module Users
  class SmsVerifier < ApplicationRecord
    extend T::Sig
    include Multitenancy
    CODE_ATTEMPTS_LIMIT = T.let(5, Integer)

    belongs_to :user
    enumerize :verifier_type, in: [:registration], default: :registration

    validates :phone_number, phony_plausible: true

    scope :enabled, -> { where(expired_at: Time.zone.now.., used_at: nil).where.not(remaining_attempts: 0) }

    sig { returns(T::Boolean) }
    def set_code
      self.code = format('%06d', SecureRandom.random_number(10**6))
      self.expired_at = 10.minutes.from_now
      self.remaining_attempts = CODE_ATTEMPTS_LIMIT
      true
    end

    sig { returns(T.nilable(String)) }
    def japan_local_phone_number
      self.phone_number&.gsub(/\A\+81/, '0')
    end
  end
end
