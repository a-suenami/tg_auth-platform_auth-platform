# typed: strict

class Membership::PlanPaymentMethodMapping < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :membership_plan, class_name: 'Membership::Plan'
  belongs_to :membership_plan_payment_method, class_name: 'Membership::PlanPaymentMethod'
  belongs_to :priceable, polymorphic: true

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :priceable_type, presence: true
end
