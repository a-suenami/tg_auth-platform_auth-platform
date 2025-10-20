# typed: false
# frozen_string_literal: true

class Membership::ContractTermBlueprint < ApplicationBlueprint
  identifier :id

  fields :status, :start_at, :end_at, :created_at, :updated_at

  association :membership_plan, blueprint: Membership::PlanBlueprint
end
