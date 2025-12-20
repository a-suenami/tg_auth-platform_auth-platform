# typed: strict

module Deliveries
  module Birthday
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

        # Note: SetupService will create new Blastengine delivery
        # when the next matching birthday users are found

        true
      end
    end
  end
end
