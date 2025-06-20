# typed: strict

module Exceptions
  module Payment
    class BaseError < Exceptions::BaseError; end

    class AlreadyHaveSubscriptions < BaseError
      sig { returns(Symbol) }
      def code
        :already_have_subscriptions
      end

      sig { returns(String) }
      def message
        I18n.t('exceptions.payment.already_have_subscriptions')
      end
    end

    class InvalidPlan < BaseError
      sig { returns(Symbol) }
      def code
        :invalid_plan
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.invalid_plan'
      end
    end

    class CardMissing < BaseError
      sig { returns(Symbol) }
      def code
        :card_missing
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.card_missing'
      end
    end

    class UnauthorizedPlan < BaseError
      sig { returns(Symbol) }
      def code
        :unauthorized_plan
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.unauthorized_plan'
      end
    end
  end
end
