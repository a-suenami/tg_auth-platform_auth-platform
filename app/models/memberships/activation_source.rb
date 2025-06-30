# typed: strict

class Memberships::ActivationSource < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'memberships__activation_sources'

  belongs_to :tenant
  belongs_to :user
  belongs_to :membership_plan, class_name: 'Memberships::Plan'
  belongs_to :user_contract, class_name: 'Memberships::UserContract'
  belongs_to :chargeable, polymorphic: true, optional: true

  has_one :user_contract_last, class_name: 'Memberships::UserContract', foreign_key: :last_membership_activation_source_id, dependent: :nullify, inverse_of: :last_membership_activation_source

  validates :payment_type, presence: true, inclusion: { in: %w[credit_card convenience campaign_code external_linkage] }

  enumerize :status, in: {
    pending: 'pending',
    active: 'active',
    expired: 'expired',
    canceled: 'canceled',
  }

  enumerize :payment_type, in: {
    credit_card: 'credit_card',
    convenience: 'convenience',
    campaign_code: 'campaign_code',
    external_linkage: 'external_linkage',
  }

  enumerize :payment_provider, in: {
    stripe: 'stripe',
    komoju: 'komoju',
    other: 'other',
  }
end
