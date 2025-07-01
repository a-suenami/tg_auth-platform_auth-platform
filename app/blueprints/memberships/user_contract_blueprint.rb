# typed: false
# frozen_string_literal: true

class Memberships::UserContractBlueprint < Blueprinter::Base
  identifier :id

  fields :expires_at, :cancel_at_period_end

  association :last_membership_activation_source, blueprint: Memberships::ActivationSourceBlueprint
end
