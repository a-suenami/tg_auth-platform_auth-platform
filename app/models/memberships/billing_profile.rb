# typed: strict

class Memberships::BillingProfile < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'memberships__billing_profiles'

  belongs_to :tenant
  belongs_to :user
  belongs_to :membership_plan, class_name: 'Memberships::Plan'
  belongs_to :membership_contract, class_name: 'Memberships::Contract'
  belongs_to :chargeable, polymorphic: true, optional: true

  validates :payment_type, presence: true, inclusion: { in: %w[credit_card convenience campaign_code external_linkage] }

  enumerize :status, in: {
    pending: 'pending',
    active: 'active',
    expired: 'expired',
    canceled: 'canceled',
  }

  enumerize :phase, in: {
    pending: 'pending',
    current: 'current',
    upcoming: 'upcoming',
    closed: 'closed',
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
