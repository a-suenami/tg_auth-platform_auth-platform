# typed: strict

class EmailTemplate < ApplicationRecord
  extend T::Sig
  include Multitenancy

  enumerize :template_type, in: %w[registration email_address_verification password_reset email_address_change]
  validates :template_type, uniqueness: { scope: [:tenant_id, :template_type] }
end
