# typed: false

module Webhook::Komoju
  class PaymentExpiredService < Webhook::Komoju::BaseService
    def execute(event_data:)
      payment_id = event_data['id']
      Rails.logger.info "Processing payment.expired: #{payment_id}"

      payment = KomojuRecord::Payment.find_by(remote_id: payment_id)
      return unless payment

      # Set tenant context for multitenancy
      set_tenant_from_payment(payment)

      payment.assign_response(event_data)
      payment.expired_at = Time.zone.now
      payment.save!

      # Update payment transaction if exists
      transaction = payment.payment_transaction
      if transaction
        transaction.update!(status: :expired)
        Rails.logger.info "Payment transaction marked as expired: #{transaction.id}"

        # Update contract and related records
        contract = transaction.membership_contract
        if contract
          contract.update!(status: :expired)

          # Delete membership_users (payment not confirmed - no membership should exist)
          contract.membership_users.destroy_all

          # Mark contract_term as closed (no 'expired' status for ContractTerm)
          contract.contract_terms.update_all(status: :closed)

          Rails.logger.info "Contract #{contract.id} marked as expired, membership_users deleted"
        end
      end
    end
  end
end
