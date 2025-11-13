# typed: false
# frozen_string_literal: true

class MembershipPlanBlueprint < ApplicationBlueprint
  identifier :id

  fields :name, :recurrence, :recurring_interval_unit, :recurring_interval_count, :billing_anchor, :anchor_day_of_month, :amount, :is_active, :enabled_at, :disabled_at, :trial_period_days, :position,
:created_at, :updated_at

  view :normal do
    association :plan_payment_methods, blueprint: MembershipPlanPaymentMethodBlueprint

    association :memberships, blueprint: MembershipBlueprint
  end
end
