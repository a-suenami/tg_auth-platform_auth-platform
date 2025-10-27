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

    class AlreadyCanceled < BaseError

      sig { returns(Symbol) }
      def code
        :already_canceled
      end

      sig { returns(String) }
      def message
        I18n.t('exceptions.payment.already_canceled')
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

    class AlreadyHaveMembership < BaseError
      sig { returns(Symbol) }
      def code
        :already_have_membership
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.already_have_membership'
      end
    end

    class PaymentMethodNotAvailable < BaseError
      sig { returns(Symbol) }
      def code
        :payment_method_not_available
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.payment_method_not_available'
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

    class CardFingerprintMissing < BaseError
      sig { returns(Symbol) }
      def code
        :card_fingerprint_missing
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.card_fingerprint_missing'
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

    class IntentNotFound < BaseError
      sig { returns(Symbol) }
      def code
        :intent_not_found
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.intent_not_found'
      end
    end

    class PlanChangeError < BaseError
      sig { returns(Symbol) }
      def code
        :plan_change_error
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.plan_change_error'
      end
    end

    class InvalidPlanChange < BaseError
      sig { returns(Symbol) }
      def code
        :invalid_plan_change
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.invalid_plan_change'
      end
    end

    # より具体的なプラン変更エラークラス
    class ContractNotActive < BaseError
      sig { returns(Symbol) }
      def code
        :contract_not_active
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.contract_not_active'
      end
    end

    class NonRecurringSubscription < BaseError
      sig { returns(Symbol) }
      def code
        :non_recurring_subscription
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.non_recurring_subscription'
      end
    end

    class DifferentMembershipPlan < BaseError
      sig { returns(Symbol) }
      def code
        :different_membership_plan
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.different_membership_plan'
      end
    end

    class UnchangeablePlan < BaseError
      sig { returns(Symbol) }
      def code
        :unchangeable_plan
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.unchangeable_plan'
      end
    end

    class NoStripeSubscription < BaseError
      sig { returns(Symbol) }
      def code
        :no_stripe_subscription
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.no_stripe_subscription'
      end
    end

    class NoCurrentContractTerm < BaseError
      sig { returns(Symbol) }
      def code
        :no_current_contract_term
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.no_current_contract_term'
      end
    end

    class StripePlanChangeError < BaseError
      sig { returns(Symbol) }
      def code
        :stripe_plan_change_error
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.stripe_plan_change_error'
      end
    end

    class InvoicePaidOnCanceledSubscription < BaseError
      sig { returns(Symbol) }
      def code
        :invoice_paid_on_canceled_subscription
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.invoice_paid_on_canceled_subscription'
      end
    end

    class PlanChangeInProgress < BaseError
      sig { returns(Symbol) }
      def code
        :plan_change_in_progress
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.plan_change_in_progress'
      end
    end

    class InvalidParams < BaseError
      sig { returns(Symbol) }
      def code
        :invalid_params
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.invalid_params'
      end
    end

    module Stripe
      class StripeError < BaseError
        sig { returns(String) }
        def message
          I18n.t 'exceptions.payment.stripe.stripe_error'
        end

        sig { returns(Symbol) }
        def code
          :stripe_error
        end
      end

      module SetupIntent
        class AlreadyCreated < BaseError
          sig { returns(String) }
          def message
            I18n.t 'exceptions.payments.stripe.setup_intent.already_created'
          end
        end

        class NotCompleted < BaseError
          sig { returns(String) }
          def message
            I18n.t 'exceptions.payments.stripe.setup_intent.not_completed'
          end
        end

        class NotCard < BaseError
          sig { returns(String) }
          def message
            I18n.t 'exceptions.payments.stripe.setup_intent.not_card'
          end
        end
      end
    end
  end
end
