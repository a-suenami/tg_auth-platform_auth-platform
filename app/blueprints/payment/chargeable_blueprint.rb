# typed: false
# frozen_string_literal: true

module Payment
  class ChargeableBlueprint < Blueprinter::Base
    identifier :id

    fields :tenant_id,
           :user_id,
           :remote_id
    #  :confirmation_secret,
    #  :confirmation_secret_type
  end
end
