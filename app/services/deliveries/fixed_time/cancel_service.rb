# typed: strict

module Deliveries
  module FixedTime
    class CancelService < BaseService
      extend T::Sig
      include Concerns::BlastengineCancel

      sig { returns(T::Boolean) }
      def execute
        schedule = delivery.schedule
        return false unless schedule&.can_cancel?

        ActiveRecord::Base.transaction do
          # Cancel on Blastengine if already reserved
          if schedule.blastengine_delivery_id.present?
            cancel_blastengine_delivery(
              blastengine_delivery_id: schedule.blastengine_delivery_id.to_i,
              logger_prefix: 'FixedTime::CancelService',
            )
          end

          schedule.cancelled!
          record_event(DeliveryEvent::Type::Cancelled.new)
        end

        true
      end
    end
  end
end
