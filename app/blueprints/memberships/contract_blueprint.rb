# typed: false
# frozen_string_literal: true

class Memberships::ContractBlueprint < Blueprinter::Base
  identifier :id

  fields :expires_at, :cancel_at_period_end, :status, :created_at, :updated_at

  view :normal do
    association :transactions, blueprint: Payment::TransactionBlueprint
  end
end
