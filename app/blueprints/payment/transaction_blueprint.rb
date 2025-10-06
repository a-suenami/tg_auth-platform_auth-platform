# typed: false
# frozen_string_literal: true

module Payment
  class TransactionBlueprint < Blueprinter::Base
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

    association :membership_contract, blueprint: Memberships::ContractBlueprint
    association :chargeable, polymorphic: true, blueprint: Payment::ChargeableBlueprint

    view :with_details do
      fields :tenant_id, :user_id, :membership_contract_id
      association :membership_contract, blueprint: Memberships::ContractBlueprint
      association :chargeable, polymorphic: true, blueprint: Payment::ChargeableBlueprint
    end
  end
end
