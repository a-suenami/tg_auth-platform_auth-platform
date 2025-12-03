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

    class StoreMissing < BaseError
      sig { returns(Symbol) }
      def code
        :store_missing
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.store_missing'
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

    class UnintentionalResponseError < BaseError
      sig { returns(Symbol) }
      def code
        :unintentional_response_error
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.unintentional_response_error'
      end

      sig { returns(T.untyped) }
      attr_accessor :response

      sig { params(response: T.untyped).void }
      def initialize(response: nil)
        @response = response
      end
    end

    class TenantNotSetError < BaseError
      sig { returns(Symbol) }
      def code
        :tenant_not_set_error
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.tenant_not_set_error'
      end
    end

    class TenantNotMatchError < BaseError
      sig { returns(Symbol) }
      def code
        :tenant_not_match_error
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.tenant_not_match_error'
      end
    end

    class CancelSubscriptionInvalidStatus < BaseError
      sig { returns(Symbol) }
      def code
        :cancel_subscription_invalid_status_error
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.payment.cancel_subscription_invalid_status_error'
      end
    end

    module Stripe
      class StripeError < BaseError
        sig { params(message: T.nilable(String)).void }
        def initialize(message = nil)
          super(message)
          @message = T.let(message || '', String)
        end

        sig { returns(String) }
        attr_reader :message

        sig { returns(Symbol) }
        def code
          :stripe_error
        end
      end

      class CardError < StripeError
        sig { params(message: T.nilable(String)).void }
        def initialize(message = nil)
          super(message)
          @message = T.let(message || '', String)
        end

        sig { returns(String) }
        def message
          I18n.t('exceptions.payment.stripe.card_error')
        end

        sig { returns(Symbol) }
        def code
          :stripe_card_error
        end
      end

      class RateLimitError < StripeError
        sig { params(message: T.nilable(String)).void }
        def initialize(message = nil)
          super(message)
          @message = T.let(message || '', String)
        end

        sig { returns(String) }
        def message
          I18n.t('exceptions.payment.stripe.rate_limit_error')
        end

        sig { returns(Symbol) }
        def code
          :stripe_rate_limit_error
        end
      end

      class InvalidRequestError < StripeError
        sig { params(message: T.nilable(String)).void }
        def initialize(message = nil)
          super(message)
          @message = T.let(message || '', String)
        end

        sig { returns(String) }
        def message
          I18n.t('exceptions.payment.stripe.invalid_request_error')
        end

        sig { returns(Symbol) }
        def code
          :stripe_invalid_request_error
        end
      end

      class AuthenticationError < StripeError
        sig { params(message: T.nilable(String)).void }
        def initialize(message = nil)
          super(message)
          @message = T.let(message || '', String)
        end

        sig { returns(String) }
        def message
          I18n.t('exceptions.payment.stripe.authentication_error')
        end

        sig { returns(Symbol) }
        def code
          :stripe_authentication_error
        end
      end

      class APIConnectionError < StripeError
        sig { params(message: T.nilable(String)).void }
        def initialize(message = nil)
          super(message)
          @message = T.let(message || '', String)
        end

        sig { returns(String) }
        def message
          I18n.t('exceptions.payment.stripe.api_connection_error')
        end

        sig { returns(Symbol) }
        def code
          :stripe_api_connection_error
        end
      end

      class APIError < StripeError
        sig { params(message: T.nilable(String)).void }
        def initialize(message = nil)
          super(message)
          @message = T.let(message || '', String)
        end

        sig { returns(String) }
        def message
          I18n.t('exceptions.payment.stripe.api_error')
        end

        sig { returns(Symbol) }
        def code
          :stripe_api_error
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

    module Konbini
      class BaseError < Payment::BaseError; end

      class AccountNotConfigured < BaseError
        sig { returns(Symbol) }
        def code
          :konbini_account_not_configured
        end

        sig { returns(String) }
        def message
          I18n.t('exceptions.payment.konbini.account_not_configured')
        end
      end

      class RecurringNotSupported < BaseError
        sig { returns(Symbol) }
        def code
          :konbini_recurring_not_supported
        end

        sig { returns(String) }
        def message
          I18n.t('exceptions.payment.konbini.recurring_not_supported')
        end
      end

      class PlanDurationTooShort < BaseError
        sig { returns(Symbol) }
        def code
          :konbini_plan_duration_too_short
        end

        sig { returns(String) }
        def message
          I18n.t('exceptions.payment.konbini.plan_duration_too_short')
        end
      end

      class InvalidStore < BaseError
        sig { returns(Symbol) }
        def code
          :konbini_invalid_store
        end

        sig { returns(String) }
        def message
          I18n.t('exceptions.payment.konbini.invalid_store')
        end
      end
    end
  end
end
