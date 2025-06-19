# typed: false
# frozen_string_literal: true

class MembershipBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :display_name, :position, :tier

  association :groups, blueprint: MembershipGroupBlueprint
  association :membership_plans, blueprint: MembershipPlanBlueprint
end
