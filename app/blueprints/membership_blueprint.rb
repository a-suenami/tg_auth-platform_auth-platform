# typed: false
# frozen_string_literal: true

class MembershipBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :display_name, :position, :tier

  association :membership_group, blueprint: MembershipGroupBlueprint
  association :membership_plans, blueprint: MembershipPlanBlueprint
end
