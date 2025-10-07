# typed: false
# frozen_string_literal: true

class Payment::SubscriptionBlueprint < ApplicationBlueprint
  identifier :id

  fields :created_at, :updated_at

  # view :normal do
  # end

  view :embedded do
    field :subscribable do |transaction, _options|
      case transaction.subscribable
      when StripeRecord::Subscription
        StripeRecord::SubscriptionBlueprint.render_as_hash(transaction.subscribable, view: :normal)
      end
    end
  end
end
