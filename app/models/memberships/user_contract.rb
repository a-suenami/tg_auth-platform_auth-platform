# typed: strict

class Memberships::UserContract < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'memberships__user_contracts'

  belongs_to :tenant
  belongs_to :user
  belongs_to :current_membership_plan, class_name: 'Memberships::Plan', inverse_of: :user_contracts
  belongs_to :next_membership_plan, class_name: 'Memberships::Plan', optional: true, inverse_of: :user_contracts_next
  belongs_to :current_membership_activation_source, class_name: 'Memberships::ActivationSource', optional: true, inverse_of: :user_contracts_current
  belongs_to :next_membership_activation_source, class_name: 'Memberships::ActivationSource', optional: true, inverse_of: :user_contracts_next

  validates :expires_at, presence: true
  validates :user_id, uniqueness: { scope: :tenant_id }
end
