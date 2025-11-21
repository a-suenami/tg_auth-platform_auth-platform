# typed: strict

# ==============================================================================
# app/models/tenant/komoju_account.rb
# ==============================================================================
class Tenant::KomojuAccount < ApplicationRecord
  include Multitenancy

  belongs_to :tenant
  belongs_to :komoju_account, class_name: 'KomojuRecord::Account'

  validates :tenant_id, uniqueness: true
  validates :default_expiry_days, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 30 }

  # Delegate methods to komoju_account
  delegate :secret_key, :webhook_secret, :display_name, to: :komoju_account

  # Alias for remote_id
  sig { returns(String) }
  def merchant_id
    T.must(komoju_account).remote_id
  end
end
