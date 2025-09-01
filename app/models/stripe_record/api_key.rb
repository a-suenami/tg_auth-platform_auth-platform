# typed: strict

# ==============================================================================
# app/models/stripe_record/api_key.rb
# ==============================================================================
class StripeRecord
  class APIKey < ApplicationRecord
    include Multitenancy
    has_one :account, validate: true, autosave: true

    attribute :secret_key, :string

    after_initialize :decrypt_secret_key, if: :persisted?

    before_validation :encrypt_secret_key

    validate :validate_secret_key
    validate :validate_account
    validates :display_name, :remote_id, :publishable_key, :secret_key_encrypted,
      presence: true
    validates :secret_key, format: { with: /\Ask_.+\z/, message: :invalid }
    validates :publishable_key, format: { with: /\Apk_.+\z/, message: :invalid }
    validates :remote_id, uniqueness: true

    private

    sig { void }
    def decrypt_secret_key
      self.secret_key = AppEncryptor.decrypt(self.secret_key_encrypted, salt: T.must(self.id))
    end

    sig { void }
    def validate_secret_key
      secret_key = T.let(self.secret_key, T.nilable(String))
      return if secret_key.blank?

      begin
        remote_account = Stripe::Account.retrieve(nil, { api_key: secret_key })

        if self.remote_id.present? && self.remote_id != remote_account.id
          self.errors.add(:secret_key, :invalid_account)
          return
        end

        self.remote_id = remote_account.id
        self.display_name = remote_account.settings.dashboard.display_name

        # account がない場合はここで initialize する
        # 各種 attributes は account 自身の callback で set される
        self.account || self.build_account
      rescue Stripe::AuthenticationError
        # do nothing
        self.errors.add(:secret_key, :authentication_error)
      end
    end

    sig { void }
    def validate_account
      account = self.account

      if account.blank?
        self.errors.add(:account, :blank)
      elsif account.invalid?
        self.errors.add(:account, :invalid)
      end
    end

    sig { void }
    def encrypt_secret_key
      secret_key = T.let(self.secret_key, T.nilable(String))
      return if secret_key.blank?

      id = self.id || SecureRandom.uuid
      self.id = id
      self.secret_key_encrypted = AppEncryptor.encrypt(secret_key, salt: id)
    end
  end
end
