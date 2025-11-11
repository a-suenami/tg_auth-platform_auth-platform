# typed: false
# frozen_string_literal: true

class KomojuRecord::PaymentBlueprint < ApplicationBlueprint
  identifier :id

  fields :remote_id, :amount, :status, :confirmation_code, :payment_deadline

  view :normal do
    field :type do |obj, _options|
      obj.class.name
    end
  end
end
