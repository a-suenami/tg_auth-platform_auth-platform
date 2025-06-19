# typed: false
# frozen_string_literal: true

class MembershipGroupBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :display_name
end
