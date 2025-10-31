# typed: false

# ==============================================================================
# app - services - user stripe - renew membership subscription service
# ==============================================================================
module UserStripe
  class RenewMembershipSubscriptionService < UserStripe::BaseService


    def execute(stripe_record_subscription:)
      if Tenant.current.nil?
        raise Exceptions::Payment::TenantNotSetError
      end

      if Tenant.current.id != stripe_record_subscription.tenant_id
        raise Exceptions::Payment::TenantNotMatchError
      end

      stripe_subscription = Stripe::Subscription.retrieve(
        { id: stripe_record_subscription.remote_id, expand: ['latest_invoice'] },
        AppStripe.request_options,
      )

      subscription_items = stripe_subscription.items.data
      stripe_current_period_end = Time.zone.at(stripe_subscription.items.first.current_period_end)
      # 1時間ほど余裕を見た上で current_period_end が stripe_record_subscription.current_period_end よりも未来であれば Stripe 側で更新処理が行われたと判断
      if stripe_record_subscription.current_period_end + 1.hour < stripe_current_period_end
        latest_invoice = stripe_subscription.latest_invoice

        raise Exceptions::Payment::UnintentionalResponseError.new(response: stripe_subscription, message: '`latest_invoice` is missing') if latest_invoice.blank?

        return if latest_invoice.status_transitions.finalized_at.blank?


        invoice_finalized_at = Time.zone.at(latest_invoice.status_transitions.finalized_at)
        if !invoice_finalized_at.between?(stripe_record_subscription.current_period_end - 1.day, stripe_record_subscription.current_period_end + 1.day)
          # もし latest invoice の finalized_at が現在の会員資格終了前後1日以内のものでなかったら
          # それは古い invoice だと判断しスキップする
        elsif latest_invoice.status == 'paid'
          contract = stripe_record_subscription.payment_subscription.membership_contract

          stripe_latest_invoice = Stripe::Invoice.retrieve(
            { id: latest_invoice.id, expand: ['payments.data.payment.payment_intent'] },
            AppStripe.request_options,
          )

          ActiveRecord::Base.transaction do

            # 1. プラン変更中かどうかチェック
            if contract.upcoming_contract_term.present?
              # TODO: プラン変更処理、プラン変更APIと同時に実装する
            end

            # 決済済みの場合
            # 2. Contractの期限更新
            contract.status = :active if contract.status == 'past_due'
            contract.expired_at = stripe_current_period_end
            contract.save!

            # 3. StripeRecord::Subscriptionの更新
            stripe_record_subscription.update!(
              current_period_end: stripe_current_period_end,
              status: stripe_subscription.status,
            )

            # 4. PaymentTransactionの更新
            create_payment_transaction(contract:, stripe_record_subscription:, stripe_latest_invoice:)



            # 5. Membership::ContractTermの更新
            current_contract_term = contract.current_contract_term
            current_contract_term.update!(
              end_at: stripe_current_period_end,
            )

            # 6. membership_userの更新
            contract.membership_users.each do |membership_user|
              membership_user.update!(
                expired_at: stripe_current_period_end,
              )
            end
          end

          # TODO: 履歴作成
          # MembershipRenewalHistories::CreateService.new.execute(user: stripe_record_subscription.user, subscription:)

          # 年額の場合のみ更新メールを送信する
          contract_term = contract.current_contract_term
          membership_plan = contract_term.membership_plan
          current_tenant = Tenant.current
          if (contract.upcoming_contract_term.nil? && membership_plan&.recurring_interval_unit == 'year') || current_tenant.tenant_stripe_account.send_subscription_update_succeeded_email_for_all_intervals
            UserStripe::SendRenewSubscriptionEmailService.new.execute!(user: contract.user, membership_contract: contract)
          end
        elsif (stripe_record_subscription.current_period_end + Tenant.current.tenant_stripe_account.membership_grace_period_minutes.minutes < Time.zone.now) || stripe_subscription.status == 'canceled'
          # 期限切れから猶予時間以上経過していたら会員資格停止
          # TODO: メンバーシップ無効処理
          # subscription.app_stripe_subscription.update!(status: stripe_subscription.status)
          # SendgridSubscriptionUpdateFailedEmailWorker.perform_async(RequestStore.store[:current_group], subscription.id)
        end

        # 更新決済が完了しておらず、また更新日時から猶予時間経過していない場合
        # -> 何もしない
      end
    rescue => e
      Sentry.configure_scope do |scope|
        scope.set_extras(subscription_id: stripe_record_subscription.id)
      end
      Sentry.capture_exception(e)
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

      payment_transaction = Payment::Transaction.create!(
        user: contract.user,
        membership_contract: contract,
        payment_type: 'credit_card',
        payment_provider: 'stripe',
        paid_amount: stripe_latest_invoice.amount / 100,
        activated_at: Time.zone.now,
        expired_at: stripe_record_subscription.current_period_end,
        chargeable: stripe_record_payment_intent,
        status: 'active',
        recurrence: true,
      )
    end
  end
end
