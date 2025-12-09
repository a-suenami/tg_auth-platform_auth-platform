# typed: strict

module Deliveries
  class PauseService < BaseService
    extend T::Sig

    sig { returns(T::Boolean) }
    def execute
      birthday = delivery.birthday
      return false unless birthday&.can_pause?

      ActiveRecord::Base.transaction do
        birthday.paused!
        record_event(DeliveryEvent::Type::Paused.new)
      end

      true
    end
  end
end
