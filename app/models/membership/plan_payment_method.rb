# typed: strict

class Membership::PlanPaymentMethod < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :membership_plan, class_name: 'Membership::Plan', inverse_of: :plan_payment_methods
  belongs_to :stripe_record_price, class_name: 'StripeRecord::Price', optional: true

  validates :payment_type, presence: true, inclusion: { in: %w[credit_card convenience campaign_code external_linkage] }
  validates :payment_type, uniqueness: { scope: :membership_plan_id }
end
