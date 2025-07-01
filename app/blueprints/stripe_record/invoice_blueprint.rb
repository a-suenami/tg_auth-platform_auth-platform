# typed: false
# frozen_string_literal: true

class StripeRecord::InvoiceBlueprint < Blueprinter::Base
  identifier :id

  fields :remote_id, :status

  association :payment_intent, blueprint: StripeRecord::PaymentIntentBlueprint
end
