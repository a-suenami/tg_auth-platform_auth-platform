# typed: false
# frozen_string_literal: true

class StripeRecord::PaymentMethodBlueprint < ApplicationBlueprint
  identifier :id

  fields :remote_id, :type, :card, :billing_details, :detached_at

  view :normal do
    field :type do |obj, _options|
      obj.class.name
    end
  end
end

