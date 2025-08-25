# typed: strict

class Membership < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :membership_group, class_name: 'Memberships::Group', optional: true

  has_many :plan_components, class_name: 'Memberships::PlanComponent', dependent: :destroy
  has_many :membership_plans, through: :plan_components, source: :membership_plan
  has_many :membership_users, class_name: 'Memberships::User', dependent: :destroy
  has_many :users, through: :membership_users
  has_many :user_achievements, class_name: 'Memberships::UserAchievement', dependent: :destroy

  validates :name, presence: true
  validates :display_name, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
