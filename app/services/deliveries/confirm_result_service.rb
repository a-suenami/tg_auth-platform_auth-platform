# typed: strict

module Deliveries
  # ConfirmResultService syncs scheduled delivery results from Blastengine
  class ConfirmResultService < BaseConfirmResultService
    extend T::Sig

    sig { params(schedule: DeliverySchedule).void }
    def initialize(schedule:)
      @schedule = schedule
      super(delivery: T.must(schedule.delivery))
    end

    private

    sig { override.returns(T.nilable(T.any(Integer, String))) }
    def blastengine_delivery_id
      @schedule.blastengine_delivery_id
    end

    sig { override.returns(T::Boolean) }
    def can_sync?
      %w[delivering delivered].include?(@schedule.status)
    end

    sig { override.params(log: T::Hash[String, T.untyped]).returns(T.nilable(DeliveryRecipient)) }
    def find_recipient(log)
      DeliveryRecipient.joins(:user)
                       .find_by(delivery_id: @delivery.id, users: { email: log['email'] })
    end

    sig { override.returns(T::Hash[Symbol, T.untyped]) }
    def delivery_result_attributes
      { delivery_schedule_id: @schedule.id }
    end

    sig { override.returns(T::Boolean) }
    def pending_recipients?
      DeliveryRecipient.exists?(delivery_id: @delivery.id, status: 'pending')
    end

    sig { override.void }
    def on_completion
      @schedule.update!(status: 'delivered')
      DeliveryEvent.record!(
        delivery: @delivery,
        event: DeliveryEvent::Type::Sent.new(payload: { source: 'bulk_sync' }),
        admin: nil,
      )
    end
  end
end
