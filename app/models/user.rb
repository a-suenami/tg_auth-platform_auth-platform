# typed: strict

class User < ApplicationRecord
  extend T::Sig
  include Multitenancy
  has_secure_password validations: false
  # password validation 英数字大文字小文字をそれぞれ1文字以上含む8文字以上
  PASSWORD_VALIDATION_REGEX = /\A(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)[!-~]{8,100}\z/
  validates :password, allow_nil: true, format: { with: PASSWORD_VALIDATION_REGEX }

  belongs_to :tenant
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
  has_one :contact_address,
    class_name: 'ContactAddress',
    dependent: :delete,
    inverse_of: :user
  has_many :delivery_addresses, dependent: :delete_all
  accepts_nested_attributes_for :contact_address, :user_profile, update_only: true

  has_many :email_verifiers,
    class_name: 'Users::EmailVerifier',
    dependent: :delete_all,
    inverse_of: :user
  has_many :sms_verifiers,
    class_name: 'Users::SmsVerifier',
    dependent: :delete_all,
    inverse_of: :user

  has_many :linked_applications,
    class_name: 'Users::LinkedApplication',
    inverse_of: :user
  has_many :oauth_applications,
    through: :linked_applications,
    inverse_of: :users

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { scope: :tenant_id, conditions: -> { where(deleted: false) } }
  validates :phone_number, phony_plausible: true

  # uniq indexの邪魔になるので空文字が入らないようにする
  before_save :convert_empty_phone_number_to_nil

  scope :active, -> { where(deleted: false, deleted_at: nil) }

  sig { params(password: String).returns(T::Boolean) }
  def authenticate!(password)
    self.password_digest.present? && BCrypt::Password.new(self.password_digest).is_password?(password)
  end

  sig { returns(T::Boolean) }
  def set_enabled_on_completion
    return true if self.enabled

    # 1. パスワードが登録済
    return false if self.password_digest.blank?
    # 2. プロフィールが登録済
    return false if self.user_profile.blank?
    # 3. 電話番号確認済(必須の場合)
    return false if self.tenant&.sms_verification_required && (self.sms_verified == false)

    self.enabled = true
    self.save!
  end

  sig { returns(T::Boolean) }
  def deleted
    self.deleted_at.present?
  end

  private

  sig { returns(NilClass) }
  def convert_empty_phone_number_to_nil
    self.phone_number = nil if self.phone_number.blank?
  end
end
