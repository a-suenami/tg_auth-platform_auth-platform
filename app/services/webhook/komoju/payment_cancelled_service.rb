# typed: false

module Webhook::Komoju
  class PaymentCancelledService < Webhook::Komoju::BaseService
    def execute(event_data:)
      payment_id = event_data['id']
      Rails.logger.info "Processing payment.cancelled: #{payment_id}"

      payment = KomojuRecord::Payment.find_by(remote_id: payment_id)
      return unless payment

      # Set tenant context for multitenancy
      set_tenant_from_payment(payment)

      payment.assign_response(event_data)
      payment.save!

      # Update payment transaction if exists
      transaction = payment.payment_transaction
      if transaction
        transaction.update!(status: :canceled)
        Rails.logger.info "Payment transaction marked as canceled: #{transaction.id}"

        # Update contract and related records
        contract = transaction.membership_contract
        if contract
          contract.update!(status: :canceled)

          # Delete membership_users (payment cancelled - no membership should exist)
          contract.membership_users.destroy_all

          # Mark contract_term as closed (no 'canceled' status for ContractTerm)
          contract.contract_terms.update_all(status: :closed)

          Rails.logger.info "Contract #{contract.id} marked as canceled, membership_users deleted"
        end
      end
    end
  end
end
