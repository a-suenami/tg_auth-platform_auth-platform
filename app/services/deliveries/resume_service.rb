# typed: strict

module Deliveries
  class ResumeService < BaseService
    extend T::Sig

    sig { returns(T::Boolean) }
    def execute
      birthday = delivery.birthday
      return false unless birthday&.can_resume?

      ActiveRecord::Base.transaction do
        birthday.ongoing!
        record_event(DeliveryEvent::Type::Resumed.new)
      end

      true
    end
  end
end
