# typed: strict

class Membership < ApplicationRecord
  extend T::Sig

  has_many :membership_users, dependent: :destroy
  has_many :users, through: :membership_users
  has_many :membership_plan_items, dependent: :destroy
  has_many :membership_plans, through: :membership_plan_items
end
