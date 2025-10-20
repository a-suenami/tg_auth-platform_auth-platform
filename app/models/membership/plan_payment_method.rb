# typed: strict

class Membership::PlanPaymentMethod < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :membership_plan, class_name: 'Membership::Plan', inverse_of: :plan_payment_methods
  has_many :plan_payment_method_mappings, class_name: 'Membership::PlanPaymentMethodMapping', foreign_key: 'membership_plan_payment_method_id', inverse_of: :membership_plan_payment_method,
dependent: :destroy

  validates :payment_type, presence: true, inclusion: { in: %w[credit_card convenience campaign_code external_linkage] }
  validates :payment_type, uniqueness: { scope: :membership_plan_id }

  def stripe_record_price
    mapping = plan_payment_method_mappings.where(priceable_type: 'StripeRecord::Price').first
    return nil unless mapping

    StripeRecord::Price.find_by(id: mapping.priceable_id)
  end
end
