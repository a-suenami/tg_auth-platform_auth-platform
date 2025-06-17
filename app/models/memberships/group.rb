# typed: strict

class Memberships::Group < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'memberships__groups'

  belongs_to :tenant

  has_many :group_assignments, class_name: 'Memberships::GroupAssignment', dependent: :destroy, inverse_of: :membership_group
  has_many :memberships, through: :group_assignments

  validates :name, presence: true, uniqueness: { scope: :tenant_id }
  validates :display_name, presence: true
end
