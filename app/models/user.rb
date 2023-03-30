# typed: strict

class User < ApplicationRecord
  extend T::Sig
  has_secure_password

  has_many :access_grants,
    class_name: 'Doorkeeper::AccessGrant',
    foreign_key: :resource_owner_id,
    dependent: :delete_all # or :destroy if you need callbacks

  has_many :access_tokens,
    class_name: 'Doorkeeper::AccessToken',
    foreign_key: :resource_owner_id,
    dependent: :delete_all # or :destroy if you need callbacks

  sig { params(password: String).returns(T::Boolean) }
  def authenticate!(password)
    # authenticate password
    BCrypt::Password.new(self.password_digest) == password
  end
end
