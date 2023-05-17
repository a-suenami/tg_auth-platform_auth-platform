# typed: strict

module Users
  class PasswordReset < ApplicationRecord
    extend T::Sig
    include Multitenancy

    belongs_to :user

    def set_code
      self.code = SecureRandom.hex(32)
      self.expired_at = 1.hour.from_now
      true
    end
  end
end
