# typed: false

# ==============================================================================
# app - services - user stripe - create service
# ==============================================================================
module Membership::Contracts
  class CreateService < BaseService

    def execute(user:, membership_plan:, payment_method:, **options)
      validate_contractable(user:, membership_plan:, payment_method:)

      case payment_method
      when 'credit_card'
        contract = process_credit_card_payment(user:, membership_plan:)
      when 'konbini', 'convenience'
        contract = process_konbini_payment(user:, membership_plan:, store: options[:store])
      else
        raise Exceptions::Payment::PaymentMethodNotAvailable
      end

      contract
    end

    private

    def process_credit_card_payment(user:, membership_plan:)
      # クレジットカード決済の実装
      # 実際の実装では、Stripeなどの決済サービスを使用
      payment_method = user.valid_stripe_card_payment_method

      unless payment_method
        raise Exceptions::Payment::CardMissing
      end

      # Stripe決済の実装（簡略化）
      # 実際の実装では、StripeRecord::PaymentIntentを使用
      UserStripe::CreateMembershipSubscriptionService.new.execute(user:, membership_plan:)
    end

    def process_konbini_payment(user:, membership_plan:, store:)
      # コンビニ決済の実装
      unless store.present?
        raise Exceptions::Payment::StoreMissing
      end

      UserKomoju::CreateMembershipPaymentService.new.execute(user:, membership_plan:, store:)
    end
  end
end
