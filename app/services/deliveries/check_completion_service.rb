# typed: false

module Deliveries
  # Service to check if all emails in a delivery have been sent
  # and update the schedule/birthday status to 'delivered'
  class CheckCompletionService
    def initialize(delivery:)
      @delivery = delivery
    end

    def execute
      return unless delivery.all_processed?

      # Update schedule status to 'delivered'
      if delivery.schedule&.delivering?
        delivery.schedule.update!(status: 'delivered')
      end

      # Record completion event (only once)
      return if already_completed?

      DeliveryEvent.record!(
        delivery: delivery,
        event: DeliveryEvent::Type::Completed.new,
        admin: nil,
      )
    end

    private

    attr_reader :delivery

    def already_completed?
      delivery.delivery_events.exists?(event_type: 'completed')
    end
  end
end
