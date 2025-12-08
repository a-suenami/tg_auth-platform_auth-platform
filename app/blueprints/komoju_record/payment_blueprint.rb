# typed: false
# frozen_string_literal: true

class KomojuRecord::PaymentBlueprint < ApplicationBlueprint
  identifier :id

  fields :remote_id, :amount, :status, :confirmation_code, :payment_deadline

  view :normal do
    field :type do |obj, _options|
      obj.class.name
    end

    field :total do |payment, _options|
      payment.komoju_data&.dig('total')
    end

    field :payment_method_fee do |payment, _options|
      payment.komoju_data&.dig('payment_method_fee')
    end

    # Konbini-specific fields from Komoju response
    field :instructions_url do |payment, _options|
      payment.komoju_data&.dig('payment_details', 'instructions_url')
    end

    field :store do |payment, _options|
      payment.komoju_data&.dig('payment_details', 'store')
    end

    field :receipt do |payment, _options|
      payment.komoju_data&.dig('payment_details', 'receipt')
    end
  end
end
