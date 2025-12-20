# typed: strict

module Deliveries
  module Birthday
    class PauseService < BaseService
      extend T::Sig
      include Concerns::BlastengineCancel

      sig { returns(T::Boolean) }
      def execute
        birthday = delivery.birthday
        return false unless birthday&.can_pause?

        ActiveRecord::Base.transaction do
          # Cancel on Blastengine if today's delivery exists
          if birthday.blastengine_delivery_id.present?
            cancel_blastengine_delivery(
              blastengine_delivery_id: birthday.blastengine_delivery_id.to_i,
              logger_prefix: 'Birthday::PauseService',
            )
            # Clear today's delivery ID since it's cancelled
            birthday.update!(blastengine_delivery_id: nil, blastengine_job_id: nil)
          end

          birthday.paused!
          record_event(DeliveryEvent::Type::Paused.new)
        end

        true
      end
    end
  end
end
