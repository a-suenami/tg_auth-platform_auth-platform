# typed: strict

module Deliveries
  class CancelService < BaseService
    extend T::Sig

    sig { returns(T::Boolean) }
    def execute
      schedule = delivery.schedule
      return false unless schedule&.can_cancel?

      ActiveRecord::Base.transaction do
        # Cancel on Blastengine if already reserved
        cancel_blastengine_delivery(schedule) if schedule.blastengine_delivery_id.present?

        schedule.cancelled!
        record_event(DeliveryEvent::Type::Cancelled.new)
      end

      true
    end

    private

    sig { params(schedule: DeliverySchedule).void }
    def cancel_blastengine_delivery(schedule)
      Blastengine::API.new.bulk_cancel(delivery_id: schedule.blastengine_delivery_id.to_i)
      Rails.logger.info("[CancelService] Cancelled Blastengine delivery #{schedule.blastengine_delivery_id}")
    rescue StandardError => e
      Rails.logger.error("[CancelService] Failed to cancel on Blastengine: #{e.message}")
      # Still proceed with local cancel - Blastengine delivery will fail anyway
    end
  end
end
