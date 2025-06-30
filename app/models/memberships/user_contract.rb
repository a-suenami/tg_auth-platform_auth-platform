# typed: strict

class Memberships::UserContract < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'memberships__user_contracts'

  belongs_to :tenant
  belongs_to :user
  belongs_to :last_membership_activation_source, class_name: 'Memberships::ActivationSource', optional: true, inverse_of: :user_contract_last

  has_many :activation_sources, class_name: 'Memberships::ActivationSource', dependent: :destroy

  validates :user_id, uniqueness: { scope: :tenant_id }

  enumerize :status, in: {
    active: 'active',
    pending: 'pending',
    expired: 'expired',
    canceled: 'canceled',
  }
end
