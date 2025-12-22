# typed: strict

class Membership::PlanComponent < ApplicationRecord
  extend T::Sig
  include Multitenancy


  belongs_to :tenant
  belongs_to :membership
  belongs_to :membership_plan, class_name: 'Membership::Plan', inverse_of: :plan_components

  validates :membership_id, uniqueness: { scope: :membership_plan_id }
end
