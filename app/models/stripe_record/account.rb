# typed: strict

# ==============================================================================
# app/models/stripe_record/account.rb
# ==============================================================================
class StripeRecord
  class Account < ApplicationRecord
    extend T::Sig

    self.inheritance_column = :_type_disabled

    belongs_to :api_key, optional: true, validate: true
    belongs_to :controlling_platform, class_name: 'Account', optional: true

    has_many :connect_accounts, class_name: 'Account', foreign_key: :controlling_platform_id, inverse_of: :controlling_platform
    has_many :tenant_stripe_accounts, class_name: 'Tenant::StripeAccount', foreign_key: :stripe_account_id, inverse_of: :stripe_account
    has_many :tenants, through: :tenant_stripe_accounts

    before_validation :set_attributes

    validate :validate_controlling_platform
    validates :remote_id, :display_name, :payments_statement_descriptor,
      presence: true
    validates :api_key, presence: true, if: -> {
      T.bind(self, Account)
      controlling_platform.blank?
    }
    validates :remote_id, uniqueness: { scope: :controlling_platform_id }

    class TypeEnum < T::Enum
      enums do
        Custom   = new('custom')
        Express  = new('express')
        Standard = new('standard')
      end
    end

    enumerize :type, enum_class: TypeEnum, skip_validations: true

    sig { returns(T::Boolean) }
    def connect_account?
      controlling_platform.present?
    end

    sig { returns(String) }
    # 管理画面用の表示名
    def ruler_full_display_name
      if self.connect_account?
        controlling_platform = T.must(self.controlling_platform)
        "#{controlling_platform.business_profile_name || controlling_platform.display_name} / #{business_profile_name || display_name}"
      else
        business_profile_name || display_name
      end
    end

    sig { params(charge_type: Tenant::StripeAccount::ChargeTypeEnum).returns(T.nilable(String)) }
    # ダイレクト支払いの場合は stripe_account として Connect 側のアカウントの ID を送信する必要があるので、その必要がある場合だけ String を返す
    # それ以外の場合は nil を返すので { stripe_account: nil } として request を飛ばせばよい
    def stripe_account_id_if_needed(charge_type:)
      # 自身が Connected アカウントでない場合（通常の決済もしくはプラットフォームアカウントの場合）は request 時の stripe_account は不要なので nil を返す
      return nil unless self.connect_account?

      stripe_account = case charge_type
      when Tenant::StripeAccount::ChargeTypeEnum::DirectCharges
        self.remote_id
      when Tenant::StripeAccount::ChargeTypeEnum::DestinationChargesApplicationFee, Tenant::StripeAccount::ChargeTypeEnum::DestinationChargesTransfer
        nil # ダイレクト支払い以外の場合も stripe_account は不要なので nil を返す
      else
        T.absurd(charge_type)
      end

      T.let(stripe_account, T.nilable(String))
    end

    private

    sig { void }
    def set_attributes
      controlling_platform = self.controlling_platform
      api_key = controlling_platform&.api_key || self.api_key
      return self.errors.add(:base, :api_key_missing) if api_key.blank?

      begin
        remote_account = Stripe::Account.retrieve(remote_id, { api_key: api_key.secret_key })

        self.remote_id                           = remote_account.id if self.remote_id.blank?
        self.type                                = remote_account.type
        self.display_name                        = remote_account.settings.dashboard.display_name
        self.business_profile_name               = remote_account.business_profile&.name
        self.payments_statement_descriptor       = remote_account.settings.payments.statement_descriptor
        self.payments_statement_descriptor_kana  = remote_account.settings.payments.statement_descriptor_kana
        self.payments_statement_descriptor_kanji = remote_account.settings.payments.statement_descriptor_kanji
      rescue Stripe::StripeError => e
        self.errors.add(:base, "Stripe APIの呼び出しに失敗しました: #{e.message}")
      end
    end

    sig { void }
    def validate_controlling_platform
      controlling_platform = self.controlling_platform
      return if controlling_platform.blank?

      if controlling_platform.remote_id == self.remote_id
        errors.add(:remote_id, '自身のStripe IDは指定できません')
        return
      end

      begin
        Stripe::Account.retrieve(remote_id, { api_key: T.must(controlling_platform.api_key).secret_key })
      rescue Stripe::AuthenticationError
        errors.add(:controlling_platform, 'この API Key では指定された Connect Account にアクセスできません')
      rescue Stripe::PermissionError
        errors.add(:controlling_platform, 'この API Key では指定された Connect Account を操作する権限がありません')
      rescue Stripe::InvalidRequestError
        errors.add(:remote_id, 'Stripe に存在しないアカウントIDです')
      end
    end
  end
end
