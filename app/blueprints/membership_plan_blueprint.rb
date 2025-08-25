# typed: false
# frozen_string_literal: true

class MembershipPlanBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :recurrence, :validity_period, :amount, :is_active, :enabled_at, :disabled_at, :trial_period_days, :position, :created_at, :updated_at

  view :normal do
    association :plan_payment_methods, blueprint: MembershipPlanPaymentMethodBlueprint

    association :memberships, blueprint: MembershipBlueprint
  end
end
