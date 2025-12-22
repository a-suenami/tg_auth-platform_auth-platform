# typed: false
# frozen_string_literal: true

class StripeRecord::InvoiceBlueprint < ApplicationBlueprint
  identifier :id

  fields :remote_id, :status, :confirmation_secret, :confirmation_secret_type
end
