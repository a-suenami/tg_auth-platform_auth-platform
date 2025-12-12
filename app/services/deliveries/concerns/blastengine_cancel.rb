# typed: strict

module Deliveries
  module Concerns
    # Shared cancel methods for Blastengine bulk delivery
    # Used by CancelService and Birthday::PauseService
    module BlastengineCancel
      extend T::Sig
      extend T::Helpers

      requires_ancestor { Kernel }

      sig { params(blastengine_delivery_id: Integer, logger_prefix: String).void }
      def cancel_blastengine_delivery(blastengine_delivery_id:, logger_prefix:)
        Blastengine::API.new.bulk_cancel(delivery_id: blastengine_delivery_id)
        Rails.logger.info("[#{logger_prefix}] Cancelled Blastengine delivery #{blastengine_delivery_id}")
      rescue StandardError => e
        Rails.logger.error("[#{logger_prefix}] Failed to cancel on Blastengine: #{e.message}")
        # Still proceed with local cancel - Blastengine delivery will fail anyway
      end
    end
  end
end
