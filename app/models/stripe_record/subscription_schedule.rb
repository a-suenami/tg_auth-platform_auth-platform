# typed: false

# ==============================================================================
# app - models - app stripe subscription schedule
# ==============================================================================
class StripeRecord
  class SubscriptionSchedule < ApplicationRecord
    include Multitenancy

    belongs_to :user
    belongs_to :subscription
  end
end
