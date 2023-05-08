# typed: strict

class User < ApplicationRecord
  extend T::Sig
  include Multitenancy
  has_secure_password validations: false

  has_many :access_grants,
    class_name: 'OauthAccessGrant',
    foreign_key: :resource_owner_id,
    dependent: :delete_all, # or :destroy if you need callbacks
    inverse_of: :resource_owner

  has_many :access_tokens,
    class_name: 'OauthAccessToken',
    foreign_key: :resource_owner_id,
    dependent: :delete_all, # or :destroy if you need callbacks
    inverse_of: :resource_owner

  has_one :user_profile, dependent: :delete
  has_one :contact_address, dependent: :delete
  has_many :delivary_addresses, dependent: :delete_all

  sig { params(password: String).returns(T::Boolean) }
  def authenticate!(password)
    # authenticate password
    BCrypt::Password.new(self.password_digest) == password
  end

  sig { returns(T::Boolean) }
  def set_email_confirm_code
    self.email_confirm_code = SecureRandom.hex(32)
    true
  end
end
