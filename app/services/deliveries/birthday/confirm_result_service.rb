# typed: strict

module Deliveries
  module Birthday
    # ConfirmResultService syncs daily birthday delivery results from Blastengine
    class ConfirmResultService < BaseConfirmResultService
      extend T::Sig

      sig { params(birthday: DeliveryBirthday).void }
      def initialize(birthday:)
        @birthday = birthday
        super(delivery: T.must(birthday.delivery))
      end

      private

      sig { override.returns(T.nilable(T.any(Integer, String))) }
      def blastengine_delivery_id
        @birthday.blastengine_delivery_id
      end

      sig { override.returns(T::Boolean) }
      def can_sync?
        @birthday.status == 'delivering'
      end

      sig { override.params(log: T::Hash[String, T.untyped]).returns(T.nilable(DeliveryRecipient)) }
      def find_recipient(log)
        DeliveryRecipient.joins(:user)
                         .find_by(
                           delivery_id: @delivery.id,
                           delivery_date: @birthday.last_setup_date,
                           users: { email: log['email'] },
                         )
      end

      sig { override.returns(T::Hash[Symbol, T.untyped]) }
      def delivery_result_attributes
        {
          delivery_birthday_id: @birthday.id,
          delivery_date: @birthday.last_setup_date,
        }
      end

      sig { override.returns(T::Boolean) }
      def pending_recipients?
        DeliveryRecipient.exists?(
          delivery_id: @delivery.id,
          delivery_date: @birthday.last_setup_date,
          status: 'pending',
        )
      end

      sig { override.void }
      def on_completion
        # Reset to ongoing for next day (birthday is recurring)
        @birthday.update!(status: 'ongoing')
      end
    end
  end
end
