# typed: false
# frozen_string_literal: true

class StripeRecord::SetupIntentBlueprint < Blueprinter::Base
  identifier :id

  fields :remote_id, :status, :usage, :client_secret, :payment_method_id, :on_behalf_of_id
end
