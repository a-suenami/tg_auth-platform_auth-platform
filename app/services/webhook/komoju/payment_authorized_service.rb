# typed: false

module Webhook::Komoju
  class PaymentAuthorizedService < Webhook::Komoju::BaseService
    def execute(event_data:)
      payment_id = event_data['id']
      Rails.logger.info "Processing payment.authorized: #{payment_id}"

      payment = KomojuRecord::Payment.find_by(remote_id: payment_id)
      return unless payment

      # Set tenant context for multitenancy
      set_tenant_from_payment(payment)

      payment.assign_response(event_data)
      payment.save!
    end
  end
end
