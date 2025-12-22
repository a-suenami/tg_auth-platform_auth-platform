# typed: false
# frozen_string_literal: true

class StripeRecord::SetupIntentBlueprint < ApplicationBlueprint
  identifier :id

  fields :remote_id, :status, :usage, :client_secret, :payment_method_id, :on_behalf_of_id

  view :normal do
    field :type do |obj, _options|
      obj.class.name
    end
  end
end
