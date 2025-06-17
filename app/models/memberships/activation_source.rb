# typed: strict

class Memberships::ActivationSource < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'memberships__activation_sources'

  belongs_to :tenant
  belongs_to :user
  belongs_to :membership_plan, class_name: 'Memberships::Plan'

  has_one :user_contracts_current, class_name: 'Memberships::UserContract', foreign_key: :current_membership_activation_source_id, dependent: :nullify,
inverse_of: :current_membership_activation_source
  has_one :user_contracts_next, class_name: 'Memberships::UserContract', foreign_key: :next_membership_activation_source_id, dependent: :nullify, inverse_of: :next_membership_activation_source

  validates :payment_type, presence: true, inclusion: { in: %w[credit_card convenience campaign_code external_linkage] }
  validates :activated_at, presence: true
  validates :expires_at, presence: true
end
