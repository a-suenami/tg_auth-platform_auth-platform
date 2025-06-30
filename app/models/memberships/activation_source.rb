# typed: strict

class Memberships::ActivationSource < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'memberships__activation_sources'

  belongs_to :tenant
  belongs_to :user
  belongs_to :membership_plan, class_name: 'Memberships::Plan'
  belongs_to :memberships__user_contract, class_name: 'Memberships::UserContract'

  has_one :user_contract_last, class_name: 'Memberships::UserContract', foreign_key: :last_membership_activation_source_id, dependent: :nullify, inverse_of: :last_membership_activation_source

  validates :payment_type, presence: true, inclusion: { in: %w[credit_card convenience campaign_code external_linkage] }
  validates :activated_at, presence: true
  validates :expires_at, presence: true
end
