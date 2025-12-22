# typed: false
# frozen_string_literal: true

class StripeRecord::PaymentIntentBlueprint < ApplicationBlueprint
  identifier :id

  fields :remote_id, :amount, :currency, :status, :client_secret

  view :normal do
    field :type do |obj, _options|
      obj.class.name
    end
  end
end
