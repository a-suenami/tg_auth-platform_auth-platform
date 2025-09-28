# typed: strict

class Memberships::UserAchievement < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'memberships__user_achievements'

  belongs_to :tenant
  belongs_to :user
  belongs_to :membership
  belongs_to :membership_plan, class_name: 'Memberships::Plan'

  validates :date, presence: true
  validates :achievement_type, presence: true
end
