# typed: strict

class Admin < ApplicationRecord
  extend T::Sig
  include Multitenancy
  has_secure_password

  sig { params(password: String).returns(T::Boolean) }
  def authenticate!(password)
    # authenticate password
    BCrypt::Password.new(self.password_digest) == password
  end
end
