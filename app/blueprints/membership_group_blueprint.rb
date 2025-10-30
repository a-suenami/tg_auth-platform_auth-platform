# typed: false
# frozen_string_literal: true

class MembershipGroupBlueprint < ApplicationBlueprint
  identifier :id

  fields :name, :display_name, :position

  view :normal do
    association :memberships, blueprint: MembershipBlueprint
  end
end
