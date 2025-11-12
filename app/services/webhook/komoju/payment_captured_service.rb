# typed: false

module Webhook::Komoju
  class PaymentCapturedService < Webhook::Komoju::BaseService
    def execute(event_data:)
      payment_id = event_data['id']
      Rails.logger.info "Processing payment.captured: #{payment_id}"

      payment = KomojuRecord::Payment.find_by(remote_id: payment_id)
      return unless payment

      # Set tenant context for multitenancy
      set_tenant_from_payment(payment)

      # Update payment record
      payment.assign_response(event_data)
      payment.captured_at = Time.zone.now
      payment.save!

      # Get transaction (should exist from service)
      transaction = payment.payment_transaction
      unless transaction
        Rails.logger.error "Transaction not found for payment: #{payment_id}"
        raise "Transaction not found for payment: #{payment_id}"
      end

      # Get contract (should exist from service)
      membership_contract = transaction.membership_contract
      unless membership_contract
        Rails.logger.error "Contract not found for transaction: #{transaction.id}"
        raise "Contract not found for transaction: #{transaction.id}"
      end

      # Calculate membership period from payment captured time
      current_contract_term = membership_contract.current_contract_term
      membership_plan = current_contract_term.membership_plan
      start_at = Time.zone.now
      end_at = membership_plan.calculate_expiry_date(from: start_at)

      # Update contract with expiry date
      membership_contract.update!(status: :active, expired_at: end_at)

      # Update transaction with activation and expiry dates
      transaction.update!(
        status: :active,
        activated_at: start_at,
        expired_at: end_at,
      )

      # Update contract term with start and end dates
      current_contract_term.update!(
        start_at: start_at,
        end_at: end_at,
      )

      # Activate membership users with expiry dates
      membership_contract.membership_users.update_all(
        status: :active,
        activated_at: start_at,
        expired_at: end_at,
      )

      Rails.logger.info "Activated contract: #{membership_contract.id}, transaction: #{transaction.id}, period: #{start_at} to #{end_at}"
    end
  end
end
