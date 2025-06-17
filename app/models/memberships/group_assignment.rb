# typed: strict

class Memberships::GroupAssignment < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'memberships__group_assignments'

  belongs_to :tenant
  belongs_to :membership
  belongs_to :membership_group, class_name: 'Memberships::Group', inverse_of: :group_assignments

  validates :membership_id, uniqueness: { scope: :membership_group_id }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(:position) }
end
