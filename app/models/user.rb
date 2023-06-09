# typed: strict

class User < ApplicationRecord
  extend T::Sig
  include Multitenancy
  has_secure_password validations: false
  # password validation 英数字大文字小文字記号をそれぞれ1文字以上含む8文字以上
  PASSWORD_VALIDATION_REGEX = %r#\A(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)(?=.*?[!-/:-@\[-`{-~])[!-~]{8,100}\z#
  validates :password, allow_nil: true, format: { with: PASSWORD_VALIDATION_REGEX }

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
  has_many :delivery_addresses, dependent: :delete_all
  accepts_nested_attributes_for :contact_address, :user_profile

  has_many :email_verifiers,
    class_name: 'Users::EmailVerifier',
    dependent: :delete_all,
    inverse_of: :user

  sig { params(password: String).returns(T::Boolean) }
  def authenticate!(password)
    # authenticate password
    BCrypt::Password.new(self.password_digest) == password
  end

  sig { returns(T::Boolean) }
  def set_enabled
    return true if self.enabled
    # 同じemailで他に有効なユーザーがいる場合は、有効にしない
    return false if User.find_by(email: self.email, enabled: true).present?

    self.enabled = true
    self.save
  end
end
