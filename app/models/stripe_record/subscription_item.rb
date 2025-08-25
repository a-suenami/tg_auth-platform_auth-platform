# typed: false

# ==============================================================================
# app/models/stripe_record/subscription_item.rb
# ==============================================================================
class StripeRecord
  class SubscriptionItem < ApplicationRecord
    include Multitenancy

    belongs_to :subscription, class_name: 'StripeRecord::Subscription'
    belongs_to :price, class_name: 'StripeRecord::Price'

    validates :remote_id, presence: true, uniqueness: true
    validates :quantity, numericality: { greater_than: 0 }
    validates :subscription_id, uniqueness: { scope: :price_id }

    # JSONB attributes with defaults
    attribute :billing_thresholds, :json, default: -> { {} }
    attribute :discounts, :json, default: -> { [] }
    attribute :metadata, :json, default: -> { {} }
    attribute :tax_rates, :json, default: -> { [] }

    def current_period_start_at
      return nil unless current_period_start

      Time.zone.at(current_period_start)
    end

    def current_period_end_at
      return nil unless current_period_end

      Time.zone.at(current_period_end)
    end
  end
end
