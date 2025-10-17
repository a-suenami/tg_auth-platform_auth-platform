# typed: false
# frozen_string_literal: true

module Payment
  class TransactionBlueprint < ApplicationBlueprint
    identifier :id

    fields :tenant_id,
           :user_id,
           :membership_contract_id,
           :payment_type,
           :payment_provider,
           :external_id,
           :status,
           :phase,
           :activated_at,
           :expires_at,
           :recurrence,
           :revision,
           :paid_amount,
           :chargeable_id,
           :chargeable_type,
           :created_at,
           :updated_at

    association :membership_contract, blueprint: Membership::ContractBlueprint

    # view :normal do
    # end

    view :embedded do
      field :chargeable do |transaction, _options|
        case transaction.chargeable
        when StripeRecord::PaymentIntent
          StripeRecord::PaymentIntentBlueprint.render_as_hash(transaction.chargeable, view: :normal)
        when StripeRecord::SetupIntent
          StripeRecord::SetupIntentBlueprint.render_as_hash(transaction.chargeable, view: :normal)
        end
      end
    end


  end
end
