# typed: strict

# ==============================================================================
# app/models/stripe_record/charge.rb
# ==============================================================================
class StripeRecord
  class Charge < ApplicationRecord
    extend T::Sig
    include Multitenancy
    include StripeConnectable

    belongs_to :user

    has_one :payment_intent_from_latest_charge, class_name: 'StripeRecord::PaymentIntent', foreign_key: :latest_charge_id, inverse_of: :latest_charge

    sig { params(remote_charge: Stripe::Charge).returns(StripeRecord::Charge) }
    def assign_remote_attributes(remote_charge) # rubocop:disable Metrics/AbcSize
      self.amount = remote_charge.amount
      self.amount_captured = remote_charge.amount_captured
      self.amount_refunded = remote_charge.amount_refunded
      self.application_id = remote_charge.application
      self.application_fee_amount = remote_charge.application_fee_amount
      self.balance_transaction_id = remote_charge.balance_transaction
      self.billing_details = remote_charge.billing_details
      self.calculated_statement_descriptor = remote_charge.calculated_statement_descriptor
      self.captured = remote_charge.captured
      self.currency = remote_charge.currency
      self.customer_id = remote_charge.customer
      self.description = remote_charge.description
      self.destination = remote_charge.destination
      self.dispute = remote_charge.dispute
      self.disputed = remote_charge.disputed
      self.failure_balance_transaction_id = remote_charge.failure_balance_transaction
      self.failure_code = remote_charge.failure_code
      self.failure_message = remote_charge.failure_message
      self.fraud_details = remote_charge.fraud_details
      self.invoice_id = remote_charge.invoice
      self.livemode = remote_charge.livemode
      self.metadata = remote_charge.metadata
      self.on_behalf_of_id = remote_charge.on_behalf_of
      self.order = remote_charge.order
      self.outcome = remote_charge.outcome
      self.paid = remote_charge.paid
      self.payment_intent_id = remote_charge.payment_intent
      self.payment_method = remote_charge.payment_method
      self.payment_method_details = remote_charge.payment_method_details
      self.radar_options = remote_charge.radar_options
      self.receipt_email = remote_charge.receipt_email
      self.receipt_number = remote_charge.receipt_number
      self.receipt_url = remote_charge.receipt_url
      self.refunded = remote_charge.refunded
      self.review_id = remote_charge.review
      self.shipping = remote_charge.shipping
      self.source = remote_charge.source
      self.source_transfer_id = remote_charge.source_transfer
      self.statement_descriptor = remote_charge.statement_descriptor
      self.statement_descriptor_suffix = remote_charge.statement_descriptor_suffix
      self.status = remote_charge.status
      self.transfer_id = remote_charge.try(:transfer)
      self.transfer_data = remote_charge.transfer_data
      self.transfer_group = remote_charge.transfer_group
      self.created = remote_charge.created
      remote_created_at = remote_charge.created
      self.created_at = Time.zone.at(remote_created_at) if remote_created_at.present?

      self
    end
  end
end
