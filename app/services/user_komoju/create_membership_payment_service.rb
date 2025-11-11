# typed: false

# ==============================================================================
# app - services - user komoju - create membership payment service
# ==============================================================================
module UserKomoju
  class CreateMembershipPaymentService < BaseService
    def execute(user:, membership_plan:, store:)
      validate_store(store)
      validate_membership_plan(membership_plan)

      komoju_payment = nil

      ActiveRecord::Base.transaction do
        # Create konbini payment via Komoju
        komoju_payment, komoju_error = create_komoju_payment(user:, membership_plan:, store:)

        if komoju_error
          raise komoju_error
        end

        unless komoju_payment
          raise StandardError, "Komoju payment was not created"
        end

        # Create contract with pending status
        contract = create_contract(user:, membership_plan:)

        # Create payment transaction
        create_payment_transaction(user:, contract:, komoju_payment:)

        # Create contract term
        create_contract_term(user:, contract:, membership_plan:)

        # Create membership users with pending status
        create_membership_users(user:, membership_plan:, contract:)

        contract
      end
    rescue => e
      # If transaction rollback, cancel the Komoju payment
      if komoju_payment&.remote_id
        cancel_komoju_payment(komoju_payment.remote_id)
      end
      raise e
    end

    private

    def validate_store(store)
      valid_stores = %w[seven-eleven lawson family-mart]
      unless valid_stores.include?(store)
        raise ArgumentError, "Invalid store: #{store}. Must be one of: #{valid_stores.join(', ')}"
      end
    end

    def validate_membership_plan(membership_plan)
      # Check if plan supports konbini payment
      unless membership_plan.plan_payment_methods.exists?(payment_type: 'convenience')
        raise StandardError, "This plan does not support konbini payment"
      end
    end

    def create_komoju_payment(user:, membership_plan:, store:)
      # Amount is stored in membership_plan, not in payment_method
      amount = membership_plan.amount

      # Convert store string to KonbiniStore enum
      store_enum = KomojuRecord::Client::Payments::KonbiniStore.deserialize(store)

      # Create payment via Komoju API
      KomojuRecord::Payment.create_with_konbini!(
        amount: amount,
        currency: 'JPY',
        store: store_enum,
        user: user,
        expiry_days: 3
      )
    end

    def create_contract(user:, membership_plan:)
      Membership::Contract.create!(
        user: user,
        tenant: user.tenant,
        status: :pending
      )
    end

    def create_payment_transaction(user:, contract:, komoju_payment:)
      Payment::Transaction.create!(
        user: user,
        tenant: user.tenant,
        membership_contract: contract,
        payment_type: :convenience,
        payment_provider: :komoju,
        chargeable: komoju_payment,
        paid_amount: komoju_payment.amount,
        status: :pending,
        recurrence: false
      )
    end

    def create_contract_term(user:, contract:, membership_plan:)
      # For konbini, we don't know end_at until payment is captured
      # Will be updated by webhook when payment is captured
      Membership::ContractTerm.create!(
        user: user,
        membership_contract: contract,
        membership_plan: membership_plan,
        payment_type: :convenience,
        start_at: Time.zone.now,
        end_at: nil, # Will be set after payment capture
        status: :current
      )
    end

    def create_membership_users(user:, membership_plan:, contract:)
      membership_plan.memberships.each do |membership|
        Membership::User.create!(
          user: user,
          membership: membership,
          status: :pending,
          membership_contract: contract
        )
      end
    end

    def cancel_komoju_payment(remote_id)
      # Best effort cancellation - don't fail if Komoju API is down
      KomojuRecord.client.payments.cancel(remote_id)
      Rails.logger.info "Cancelled Komoju payment: #{remote_id}"
    rescue => e
      Rails.logger.error "Failed to cancel Komoju payment: #{remote_id}, error: #{e.message}"
      # Don't re-raise - service already failed, this is just cleanup
    end
  end
end
