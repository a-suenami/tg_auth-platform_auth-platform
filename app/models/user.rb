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

  has_many :shopify_customers, class_name: 'ShopifyRecord::Customer', dependent: :delete_all
  # Stripe
  has_many :stripe_setup_intents, class_name: 'StripeRecord::SetupIntent'
  has_many :stripe_payment_methods, class_name: 'StripeRecord::PaymentMethod'

  # Membership
  has_many :membership_users, class_name: 'Memberships::User', dependent: :destroy
  has_many :memberships, through: :membership_users
  has_many :membership_user_contracts, class_name: 'Memberships::UserContract', dependent: :destroy
  has_many :membership_activation_sources, class_name: 'Memberships::ActivationSource', dependent: :destroy
  has_many :membership_user_achievements, class_name: 'Memberships::UserAchievement', dependent: :destroy
  has_many :membership_trial_histories, class_name: 'Memberships::TrialHistory', dependent: :destroy
  # stripe
  has_many :stripe_subscriptions, class_name: 'StripeRecord::Subscription'

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { scope: :tenant_id, conditions: -> { where(deleted_at: nil) } }
  validates :phone_number, phony_plausible: true

  # uniq indexの邪魔になるので空文字が入らないようにする
  before_save :convert_empty_phone_number_to_nil

  scope :active, -> { where(deleted: false, deleted_at: nil) }

  sig { params(password: String).returns(T::Boolean) }
  def authenticate!(password)
    self.password_digest.present? && BCrypt::Password.new(self.password_digest).is_password?(password)
  end

  sig { returns(T::Boolean) }
  def deleted
    self.deleted_at.present?
  end

  sig { params(tenant_stripe_account: Tenant::StripeAccount).returns(Mangrove::Result[Stripe::Customer, Stripe::StripeError]) }
  def create_stripe_customer(tenant_stripe_account:)
    charge_type = tenant_stripe_account.charge_type

    stripe_account = case charge_type&.enum
    when Tenant::StripeAccount::ChargeTypeEnum::DirectCharges
      T.must(tenant_stripe_account.stripe_account&.remote_id)
    when NilClass, Tenant::StripeAccount::ChargeTypeEnum::DestinationChargesApplicationFee, Tenant::StripeAccount::ChargeTypeEnum::DestinationChargesTransfer
      nil
    else
      T.absurd(charge_type)
    end

    result = StripeRecord::Client::Customer.create(
      {
        name: self.user_profile&.name,
        phone: self.phone_number,
        email: self.email,
        metadata: {
          user_id: self.id,
        },
      },
      stripe_account_id: T.let(stripe_account, T.nilable(String)),
      api_key: tenant_stripe_account.api_key,
    )
    return Mangrove::Result.err(result.err_inner) if result.is_a?(Mangrove::Result::Err)

    remote_customer = result.ok_inner

    self.update_columns(
      payment_provider: AuthPlatform::PaymentProviderEnum::Stripe.serialize,
      payment_customer_id: remote_customer.id,
    )

    Mangrove::Result.ok(remote_customer)
  end

  sig { returns(T.nilable(StripeRecord::PaymentMethod)) }
  def valid_stripe_card_payment_method
    self.stripe_payment_methods.valid.first
  end

  sig { returns(StripeRecord::PaymentMethod) }
  def valid_stripe_card_payment_method!
    self.stripe_payment_methods.valid.first!
  end

  sig { returns(Mangrove::Result[TrueClass, Stripe::StripeError]) }
  def detach_stripe_payment_methods
    self.stripe_payment_methods.valid.each do |payment_method|
      ApplicationRecord.transaction do
        payment_method.update_columns(detached_at: Time.zone.now)

        detached_result = StripeRecord::Client::PaymentMethod.detach(
          payment_method.remote_id,
          stripe_account_id: payment_method.stripe_account_id_if_needed,
          api_key: T.must(T.must(payment_method.api_key_account).api_key),
        )
        # rollback のため Stripe::StripeError を raise するが必ず method 内で rescue すること
        raise detached_result.err_inner if detached_result.is_a?(Mangrove::Result::Err)
      end
    end

    Mangrove::Result.ok(true)
  rescue Stripe::StripeError => e
    Mangrove::Result.err(e)
  end

  private

  sig { returns(NilClass) }
  def convert_empty_phone_number_to_nil
    self.phone_number = nil if self.phone_number.blank?
  end
end
