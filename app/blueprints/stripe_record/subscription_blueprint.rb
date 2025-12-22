# typed: false
# frozen_string_literal: true

class StripeRecord::SubscriptionBlueprint < ApplicationBlueprint
  identifier :id

  fields :remote_id, :status

  view :normal do
    field :type do |obj, _options|
      obj.class.name
    end
  end

  view :embedded do
    association :invoices, blueprint: StripeRecord::InvoiceBlueprint
    association :pending_setup_intent, blueprint: StripeRecord::SetupIntentBlueprint
  end
end
