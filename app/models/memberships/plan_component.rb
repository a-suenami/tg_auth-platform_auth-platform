# typed: strict

class Memberships::PlanComponent < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'memberships__plan_components'

  belongs_to :tenant
  belongs_to :membership
  belongs_to :membership_plan, class_name: 'Memberships::Plan', inverse_of: :plan_components

  validates :membership_id, uniqueness: { scope: :membership_plan_id }
end
