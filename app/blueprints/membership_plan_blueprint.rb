# typed: false
# frozen_string_literal: true

class MembershipPlanBlueprint < ApplicationBlueprint
  KONBINI_STORES = %w[
    konbini_seven_eleven
    konbini_lawson
    konbini_family_mart
  ].freeze

  identifier :id

  fields :name, :recurrence, :recurring_interval_unit, :recurring_interval_count, :billing_anchor, :anchor_day_of_month, :amount, :is_active, :enabled_at, :disabled_at, :trial_period_days, :position,
:created_at, :updated_at

  view :normal do
    # Expand 'convenience' payment_type to individual konbini stores
    field :plan_payment_methods do |membership_plan, _options|
      membership_plan.plan_payment_methods.flat_map do |pm|
        if pm.payment_type == 'convenience'
          KONBINI_STORES.map { |store| { payment_type: store } }
        else
          { payment_type: pm.payment_type }
        end
      end
    end

    association :memberships, blueprint: MembershipBlueprint
  end
end
