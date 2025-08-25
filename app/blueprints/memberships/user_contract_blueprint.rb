# typed: false
# frozen_string_literal: true

class Memberships::UserContractBlueprint < Blueprinter::Base
  identifier :id

  fields :expires_at, :cancel_at_period_end, :status, :created_at, :updated_at

  view :normal do
    association :billing_profiles, blueprint: Memberships::BillingProfileBlueprint
  end
end
