# typed: strict

module Deliveries
  class PublishService < BaseService
    extend T::Sig

    sig { returns(T::Boolean) }
    def execute
      child = delivery.schedule || delivery.birthday
      return false unless child

      ActiveRecord::Base.transaction do
        child.update!(
          status: delivery.schedule_type? ? 'scheduled' : 'ongoing',
          published_at: Time.current,
          published_by: admin,
        )
        record_event(DeliveryEvent::Type::Published.new)
      end

      true
    end
  end
end
