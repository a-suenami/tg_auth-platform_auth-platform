# typed: false
# frozen_string_literal: true

class Memberships::ContractBlueprint < ApplicationBlueprint
  identifier :id

  fields :expires_at, :cancel_at_period_end, :status, :created_at, :updated_at

  view :normal do
    association :contract_terms, blueprint: Memberships::ContractTermBlueprint
  end

  view :detailed do
    include_view :normal
    association :payment_transactions, blueprint: Payment::TransactionBlueprint, view: :embedded
    association :payment_subscription, blueprint: Payment::SubscriptionBlueprint, view: :embedded
  end
end
