# typed: false
# frozen_string_literal: true

class StripeRecord::PaymentIntentBlueprint < Blueprinter::Base
  identifier :id

  fields :remote_id, :amount, :currency, :status, :client_secret
end
