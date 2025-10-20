# typed: false
# frozen_string_literal: true

module Payment
  class ChargeableBlueprint < ApplicationBlueprint
    identifier :id

    fields :tenant_id,
           :user_id,
           :remote_id
  end
end
