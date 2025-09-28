# typed: false
# frozen_string_literal: true

class MembershipBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :display_name, :position, :tier

  view :normal do
    association :membership_group, blueprint: MembershipGroupBlueprint
    association :membership_plans, blueprint: MembershipPlanBlueprint
  end

  view :personal do
    association :membership_group, blueprint: MembershipGroupBlueprint
  end
end
