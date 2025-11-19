# typed: strict

# ==============================================================================
# app/models/komoju_record/account.rb
# ==============================================================================
class KomojuRecord
  class Account < ApplicationRecord
    extend T::Sig
    include Multitenancy

    has_one :tenant_komoju_account, class_name: 'Tenant::KomojuAccount', foreign_key: :komoju_account_id, inverse_of: :komoju_account

    # Virtual attributes for decrypted values
    attribute :secret_key, :string
    attribute :webhook_secret, :string

    after_initialize :decrypt_credentials, if: :persisted?
    before_validation :encrypt_credentials

    validates :remote_id, :display_name, :secret_key_encrypted, :webhook_secret_encrypted,
      presence: true
    validates :remote_id, uniqueness: true
    validates :secret_key, format: { with: /\Ask_.+\z/, message: :invalid }, allow_nil: true
    validates :webhook_secret, presence: true, on: :create

    # Admin display name for Ruler
    sig { returns(String) }
    def ruler_display_name
      "#{display_name} (#{remote_id})"
    end

    private

    sig { void }
    def decrypt_credentials
      return unless secret_key_encrypted.present? && webhook_secret_encrypted.present?

      self.secret_key = AppEncryptor.decrypt(self.secret_key_encrypted, salt: self.id)
      self.webhook_secret = AppEncryptor.decrypt(self.webhook_secret_encrypted, salt: self.id)
    end

    sig { void }
    def encrypt_credentials
      # Encrypt secret_key if changed
      if secret_key.present?
        id = T.let(self.id, T.nilable(String)) || SecureRandom.uuid
        self.id = id
        self.secret_key_encrypted = AppEncryptor.encrypt(secret_key, salt: id)
      end

      # Encrypt webhook_secret if changed
      if webhook_secret.present?
        id = T.let(self.id, T.nilable(String)) || SecureRandom.uuid
        self.id = id
        self.webhook_secret_encrypted = AppEncryptor.encrypt(webhook_secret, salt: id)
      end
    end
  end
end
