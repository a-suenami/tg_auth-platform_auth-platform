# typed: strict

module Deliveries
  module FixedTime
    # Service to check if all emails in a scheduled delivery have been sent
    # and update the schedule status to 'delivered'
    class CheckCompletionService
      extend T::Sig

      sig { params(delivery: Delivery).void }
      def initialize(delivery:)
        @delivery = delivery
      end

      sig { void }
      def execute
        return unless @delivery.all_processed?

        # Update schedule status to 'delivered'
        schedule = @delivery.schedule
        if schedule&.delivering?
          schedule.update!(status: 'delivered')
        end

        # Record completion event (only once)
        return if already_completed?

        DeliveryEvent.record!(
          delivery: @delivery,
          event: DeliveryEvent::Type::Completed.new,
          admin: nil,
        )
      end

      private

      sig { returns(T::Boolean) }
      def already_completed?
        @delivery.delivery_events.exists?(event_type: 'completed')
      end
    end
  end
end
