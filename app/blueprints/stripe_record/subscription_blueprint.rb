# typed: false
# frozen_string_literal: true

class StripeRecord::SubscriptionBlueprint < Blueprinter::Base
  identifier :id

  fields :remote_id, :status

  association :invoices, blueprint: StripeRecord::InvoiceBlueprint
end
