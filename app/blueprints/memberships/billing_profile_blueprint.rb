# typed: false
# frozen_string_literal: true

class Memberships::BillingProfileBlueprint < Blueprinter::Base
  identifier :id

  fields :payment_type, :payment_provider, :external_id, :activated_at, :expires_at, :membership_plan_id

  association :chargeable, blueprint: StripeRecord::SubscriptionBlueprint
end
