# typed: strict

class Memberships::Plan < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'memberships__plans'

  belongs_to :tenant
  belongs_to :membership

  has_many :plan_payment_methods, class_name: 'Memberships::PlanPaymentMethod', dependent: :destroy
  has_many :plan_components, class_name: 'Memberships::PlanComponent', dependent: :destroy
  has_many :user_contracts, class_name: 'Memberships::UserContract', foreign_key: :current_membership_plan_id, dependent: :nullify
  has_many :user_contracts_next, class_name: 'Memberships::UserContract', foreign_key: :next_membership_plan_id, dependent: :nullify
  has_many :activation_sources, class_name: 'Memberships::ActivationSource', dependent: :destroy
  has_many :user_achievements, class_name: 'Memberships::UserAchievement', dependent: :destroy

  validates :billing_cycle, presence: true, inclusion: { in: %w[monthly yearly one-time] }
  validates :validity_period, presence: true, inclusion: { in: %w[month year] }
  validates :amount, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :billing_cycle, uniqueness: { scope: [:tenant_id, :membership_id] }
end
