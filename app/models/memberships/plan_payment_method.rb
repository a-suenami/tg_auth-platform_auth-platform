# typed: strict

class Memberships::PlanPaymentMethod < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'memberships__plan_payment_methods'

  belongs_to :tenant
  belongs_to :membership_plan, class_name: 'Memberships::Plan', inverse_of: :plan_payment_methods

  validates :payment_type, presence: true, inclusion: { in: %w[credit_card convenience campaign_code external_linkage] }
  validates :payment_type, uniqueness: { scope: :membership_plan_id }
end
