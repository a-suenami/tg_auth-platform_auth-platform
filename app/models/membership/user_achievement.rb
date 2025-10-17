# typed: strict

class Membership::UserAchievement < ApplicationRecord
  extend T::Sig
  include Multitenancy


  belongs_to :tenant
  belongs_to :user
  belongs_to :membership
  belongs_to :membership_plan, class_name: 'Membership::Plan'

  validates :date, presence: true
  validates :achievement_type, presence: true
end
