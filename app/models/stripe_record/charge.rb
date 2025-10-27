# typed: strict

class StripeRecord
  class Charge < ApplicationRecord
    include Multitenancy

    belongs_to :user
    belongs_to :payment_intent, class_name: 'StripeRecord::PaymentIntent'
    belongs_to :api_key_account, class_name: 'StripeRecord::Account'

    sig { params(remote_charge: Stripe::Charge).returns(StripeRecord::Charge) }
    def assign_remote_attributes(remote_charge) # rubocop:disable Metrics/AbcSize
      self.amount = remote_charge.amount
      self.amount_captured = remote_charge.amount_captured
      self.amount_refunded = remote_charge.amount_refunded
      self.application_id = remote_charge.application
      self.application_fee_amount = remote_charge.application_fee_amount
      balance_transaction = remote_charge.balance_transaction
      self.balance_transaction_id = balance_transaction&.id
      self.billing_details = remote_charge.billing_details
      self.calculated_statement_descriptor = remote_charge.calculated_statement_descriptor
      self.captured = remote_charge.captured
      self.currency = remote_charge.currency
      customer = remote_charge.customer
      self.customer_id = case customer
                         when String
                           customer
                         when Stripe::Customer
                           customer.id
      end
      self.description = remote_charge.description
      # self.destination = remote_charge.destination&.id  # destination method does not exist on Stripe::Charge
      self.dispute = remote_charge.dispute
      self.disputed = remote_charge.disputed
      self.failure_balance_transaction_id = remote_charge.failure_balance_transaction
      self.failure_code = remote_charge.failure_code
      self.failure_message = remote_charge.failure_message
      self.fraud_details = remote_charge.try(:fraud_details)
      # self.invoice_id = remote_charge.invoice&.id  # invoice method does not exist on Stripe::Charge
      self.livemode = remote_charge.livemode
      self.metadata = remote_charge.metadata
      self.on_behalf_of_id = remote_charge.on_behalf_of
      # self.order = remote_charge.order&.id  # order method does not exist on Stripe::Charge
      self.outcome = remote_charge.try(:outcome)
      self.paid = remote_charge.paid
      # # self.payment_intent_id = remote_charge.payment_intent
      self.payment_method = remote_charge.payment_method
      self.payment_method_details = remote_charge.try(:payment_method_details)
      self.radar_options = remote_charge.try(:radar_options)
      self.receipt_email = remote_charge.receipt_email
      self.receipt_number = remote_charge.receipt_number
      self.receipt_url = remote_charge.receipt_url
      self.refunded = remote_charge.refunded
      self.review_id = remote_charge.review
      self.shipping = remote_charge.try(:shipping)
      self.source = remote_charge.source&.id
      self.source_transfer_id = remote_charge.try(:source_transfer)
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
