# typed: strict

module Deliveries
  class CancelService < BaseService
    extend T::Sig

    sig { returns(T::Boolean) }
    def execute
      schedule = delivery.schedule
      return false unless schedule&.can_cancel?

      ActiveRecord::Base.transaction do
        schedule.cancelled!
        record_event(DeliveryEvent::Type::Cancelled.new)
      end

      true
    end
  end
end
