# typed: false
# frozen_string_literal: true

class MembershipPlanBlueprint < Blueprinter::Base
  identifier :id

  fields :billing_cycle, :validity_period, :amount

  association :plan_payment_methods, blueprint: MembershipPlanPaymentMethodBlueprint
end
