# typed: false
# frozen_string_literal: true

class Memberships::PlanBlueprint < ApplicationBlueprint
  identifier :id

  fields :name, :recurrence, :recurring_interval_unit, :recurring_interval_count, :billing_anchor, :anchor_day_of_month, :amount, :is_active, :enabled_at, :disabled_at, :trial_period_days, :position,
:created_at, :updated_at

  # association :plan_payment_methods, blueprint: Memberships::PlanPaymentMethodBlueprint
  association :memberships, blueprint: MembershipBlueprint
end
