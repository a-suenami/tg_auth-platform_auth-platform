# typed: strict

class Memberships::Plan < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'memberships__plans'

  belongs_to :tenant

  has_many :plan_payment_methods, class_name: 'Memberships::PlanPaymentMethod', dependent: :destroy, inverse_of: :membership_plan
  has_many :plan_components, class_name: 'Memberships::PlanComponent', dependent: :destroy, inverse_of: :membership_plan
  has_many :memberships, through: :plan_components
  has_many :billing_profiles, class_name: 'Memberships::BillingProfile', dependent: :destroy
  has_many :user_achievements, class_name: 'Memberships::UserAchievement', dependent: :destroy
  has_many :trial_histories, class_name: 'Memberships::TrialHistory', dependent: :destroy, inverse_of: :membership_plan

  accepts_nested_attributes_for :plan_payment_methods, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :plan_components, allow_destroy: true, reject_if: :all_blank

  validates :recurrence, inclusion: { in: [true, false] }
  validates :validity_period, presence: true, inclusion: { in: %w[month year] }
  validates :amount, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
