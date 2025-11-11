# typed: false

# ==============================================================================
# app - services - user stripe - renew membership subscription service
# ==============================================================================
module UserStripe
  class RenewMembershipSubscriptionService < UserStripe::BaseService


    def execute(stripe_record_subscription:)
      validate_tenant!(stripe_record_subscription)
      stripe_subscription = fetch_stripe_subscription(stripe_record_subscription)
      stripe_current_period_end = extract_current_period_end(stripe_subscription)

      return unless subscription_renewed?(stripe_record_subscription, stripe_current_period_end)

      process_renewal(stripe_record_subscription, stripe_subscription, stripe_current_period_end)
    rescue => e
      Sentry.configure_scope do |scope|
        scope.set_extras(subscription_id: stripe_record_subscription.id)
      end
      Sentry.capture_exception(e)
    end

    private

    def validate_tenant!(stripe_record_subscription)
      if Tenant.current.nil?
        raise Exceptions::Payment::TenantNotSetError
      end

      if Tenant.current.id != stripe_record_subscription.tenant_id
        raise Exceptions::Payment::TenantNotMatchError
      end
    end

    def fetch_stripe_subscription(stripe_record_subscription)
      Stripe::Subscription.retrieve(
        { id: stripe_record_subscription.remote_id, expand: ['latest_invoice'] },
        AppStripe.request_options,
      )
    end

    def extract_current_period_end(stripe_subscription)
      Time.zone.at(stripe_subscription.items.first.current_period_end)
    end

    def subscription_renewed?(stripe_record_subscription, stripe_current_period_end)
      stripe_record_subscription.current_period_end + 1.hour < stripe_current_period_end
    end

    def process_renewal(stripe_record_subscription, stripe_subscription, stripe_current_period_end)
      latest_invoice = stripe_subscription.latest_invoice
      raise Exceptions::Payment::UnintentionalResponseError.new(response: stripe_subscription, message: '`latest_invoice` is missing') if latest_invoice.blank?

      if latest_invoice.status_transitions.finalized_at.blank?
        handle_unfinalized_invoice(stripe_record_subscription, stripe_subscription)
        return
      end

      invoice_finalized_at = Time.zone.at(latest_invoice.status_transitions.finalized_at)
      return unless invoice_finalized_at.between?(stripe_record_subscription.current_period_end - 1.day, stripe_record_subscription.current_period_end + 1.day)

      if latest_invoice.status == 'paid'
        handle_paid_invoice(stripe_record_subscription, stripe_subscription, latest_invoice, stripe_current_period_end)
      elsif should_expire?(stripe_record_subscription, stripe_subscription)
        expire_renewal(stripe_record_subscription, stripe_subscription)
      end
    end

    def handle_unfinalized_invoice(stripe_record_subscription, stripe_subscription)
      contract = stripe_record_subscription.payment_subscription.membership_contract
      if stripe_record_subscription.current_period_end + Tenant.current.tenant_stripe_account.membership_grace_period_minutes.minutes < Time.zone.now
        membership_set_past_due(contract:)
      elsif stripe_subscription.status == 'canceled'
        ActiveRecord::Base.transaction do
          expire_contract(contract:)
          expire_subscription(stripe_record_subscription:, stripe_subscription:)
        end
      end
    end

    def handle_paid_invoice(stripe_record_subscription, stripe_subscription, latest_invoice, stripe_current_period_end)
      contract = stripe_record_subscription.payment_subscription.membership_contract
      stripe_latest_invoice = fetch_stripe_latest_invoice(latest_invoice)

      ActiveRecord::Base.transaction do
        # 1. プラン変更中かどうかチェック
        if contract.upcoming_contract_term.present?
          # TODO: プラン変更処理、プラン変更APIと同時に実装する
        end

        update_contract_for_renewal(contract, stripe_current_period_end)
        update_stripe_record_subscription(stripe_record_subscription, stripe_subscription, stripe_current_period_end)
        create_payment_transaction(contract:, stripe_record_subscription:, stripe_latest_invoice:)
        update_contract_term(contract, stripe_current_period_end)
        update_membership_users(contract, stripe_current_period_end)
      end

      # TODO: 履歴作成
      # MembershipRenewalHistories::CreateService.new.execute(user: stripe_record_subscription.user, subscription:)

      send_renewal_email_if_needed(contract)
    end

    def fetch_stripe_latest_invoice(latest_invoice)
      Stripe::Invoice.retrieve(
        { id: latest_invoice.id, expand: ['payments.data.payment.payment_intent'] },
        AppStripe.request_options,
      )
    end

    def update_contract_for_renewal(contract, stripe_current_period_end)
      contract.status = :active if contract.status == 'past_due'
      contract.expired_at = stripe_current_period_end
      contract.save!
    end

    def update_stripe_record_subscription(stripe_record_subscription, stripe_subscription, stripe_current_period_end)
      stripe_record_subscription.update!(
        current_period_end: stripe_current_period_end,
        status: stripe_subscription.status,
      )
    end

    def update_contract_term(contract, stripe_current_period_end)
      current_contract_term = contract.current_contract_term
      current_contract_term.update!(
        end_at: stripe_current_period_end,
      )
    end

    def update_membership_users(contract, stripe_current_period_end)
      contract.membership_users.each do |membership_user|
        membership_user.update!(
          status: 'active',
          expired_at: stripe_current_period_end,
        )
      end
    end

    def send_renewal_email_if_needed(contract)
      contract_term = contract.current_contract_term
      membership_plan = contract_term.membership_plan
      current_tenant = Tenant.current
      is_year_plan_without_upcoming = contract.upcoming_contract_term.nil? && membership_plan&.recurring_interval_unit == 'year'
      should_send_email_for_all = current_tenant.tenant_stripe_account.send_subscription_update_succeeded_email_for_all_intervals
      return unless is_year_plan_without_upcoming || should_send_email_for_all

      UserStripe::SendRenewSubscriptionEmailService.new.execute!(user: contract.user, membership_contract: contract)
    end

    def should_expire?(stripe_record_subscription, stripe_subscription)
      grace_period_passed = stripe_record_subscription.current_period_end + Tenant.current.tenant_stripe_account.membership_grace_period_minutes.minutes < Time.zone.now
      grace_period_passed || stripe_subscription.status == 'canceled'
    end

    def expire_renewal(stripe_record_subscription, stripe_subscription)
      contract = stripe_record_subscription.payment_subscription.membership_contract
      ActiveRecord::Base.transaction do
        expire_contract(contract:)
        expire_subscription(stripe_record_subscription:, stripe_subscription:)
      end
      # 期限切れから猶予時間以上経過していたら会員資格停止
      # TODO: メンバーシップ無効処理
      # SendgridSubscriptionUpdateFailedEmailWorker.perform_async(RequestStore.store[:current_group], subscription.id)
    end

    def create_payment_transaction(contract:, stripe_record_subscription:, stripe_latest_invoice:)
      payment_intent = stripe_latest_invoice.payments.data.first.payment.payment_intent

      stripe_record_invoice = StripeRecord::Invoice.find_or_initialize_by(remote_id: stripe_latest_invoice.id)
      stripe_record_invoice.user = contract.user
      stripe_record_invoice.tenant_id = contract.tenant_id
      stripe_record_invoice.status = stripe_latest_invoice.status
      stripe_record_invoice.payment_source = stripe_record_subscription
      stripe_record_invoice.confirmation_secret = stripe_latest_invoice&.confirmation_secret&.client_secret
      stripe_record_invoice.confirmation_secret_type = 'payment_intent' if stripe_latest_invoice&.confirmation_secret&.client_secret.present?
      stripe_record_invoice.save!

      stripe_record_payment_intent = StripeRecord::PaymentIntent.find_or_initialize_by(remote_id: payment_intent.id)
      stripe_record_payment_intent.user = contract.user
      stripe_record_payment_intent.tenant_id = contract.tenant_id
      stripe_record_payment_intent.invoice = stripe_record_invoice
      stripe_record_payment_intent.assign_remote_attributes(payment_intent)
      stripe_record_payment_intent.api_key_account = Tenant.current.tenant_stripe_account.stripe_account
      stripe_record_payment_intent.chargeable = stripe_record_subscription
      stripe_record_payment_intent.save!

      Payment::Transaction.create!(
        user: contract.user,
        membership_contract: contract,
        payment_type: 'credit_card',
        payment_provider: 'stripe',
        paid_amount: stripe_latest_invoice.amount_paid,
        activated_at: Time.zone.now,
        expired_at: stripe_record_subscription.current_period_end,
        chargeable: stripe_record_payment_intent,
        status: 'active',
        recurrence: true,
      )
    end

    def expire_contract(contract:)
      contract.update!(
        status: 'canceled',
      )

      contract.membership_users.each do |membership_user|
        membership_user.update!(
          status: 'closed',
        )
      end

      contract.current_contract_term.update!(
        status: 'closed',
        expired_at: Time.zone.now,
      )
    end

    def expire_subscription(stripe_record_subscription:, stripe_subscription:)
      stripe_record_subscription.update!(
        status: stripe_subscription.status,
      )
    end

    def membership_set_past_due(contract:)
      contract.update!(
        status: 'expired',
      )

      contract.membership_users.each do |membership_user|
        membership_user.update!(
          status: 'past_due',
        )
      end
    end
  end
end
