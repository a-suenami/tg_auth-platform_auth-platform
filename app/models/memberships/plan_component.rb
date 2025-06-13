# typed: strict

class Memberships::PlanComponent < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'memberships__plan_components'

  belongs_to :membership_plan, class_name: 'Memberships::Plan'
  belongs_to :membership

  validates :membership_id, uniqueness: { scope: :membership_plan_id }
end
