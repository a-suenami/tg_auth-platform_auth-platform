# typed: false

module UserStripe
  class CompleteContractService < UserStripe::BaseService
    def execute(contract)
      # TODO: 完了済みの場合も2重リクエスト対策として冪等に処理。ただし、明らかに新規登録でない場合はエラーとする

      ActiveRecord::Base.transaction do
        # StripeRecord::Subscriptionを取得
        stripe_record_subscription = contract.payment_subscription&.subscribable
        unless stripe_record_subscription
          raise Exceptions::Payment::InvalidPlan, "StripeRecord::Subscription not found for contract #{contract.id}"
        end

        # Stripe APIから最新のsubscription情報を取得
        stripe_record_subscription.refresh!

        # Contractのステータスをアクティブに変更
        contract.update!(
          status: 'active',
        )

        # Payment::Subscriptionのステータスをアクティブに変更
        contract.payment_subscription

        # Payment::Transactionのステータスをアクティブに変更
        payment_transaction = contract.payment_transactions.order(created_at: :desc).first
        payment_transaction.update!(
          status: 'active',
        )

        # Stripeから次回更新時間を取得
        next_period_end = get_next_period_end_from_stripe(stripe_record_subscription, contract)

        # Contractの有効期限を設定
        contract.update!(
          expired_at: next_period_end,
        )

        # Membership::Userのステータスを有効に変更
        update_membership_user(contract, next_period_end)

        # トライアル履歴を作成
        if stripe_record_subscription.trial_start.present?
          create_trial_history(contract:, stripe_record_subscription:)
        end

        Rails.logger.info "User contract #{contract.id} completed successfully"
      end
    end

    private

    def get_next_period_end_from_stripe(stripe_record_subscription, contract)
      if stripe_record_subscription.current_period_end.present?
        Time.zone.at(stripe_record_subscription.current_period_end)
      else
        # フォールバック: プラン情報から計算
        membership_plan = contract.current_contract_term.membership_plan
        calculate_recurring_expiry_date(Time.zone.now, membership_plan)
      end
    end

    def calculate_recurring_expiry_date(activated_at, plan)
      # recurring_interval_unitとrecurring_interval_countを使用して契約期間を計算
      case plan.recurring_interval_unit
      when 'day'
        activated_at + plan.recurring_interval_count.days
      when 'week'
        activated_at + plan.recurring_interval_count.weeks
      when 'month'
        activated_at + plan.recurring_interval_count.months
      when 'year'
        activated_at + plan.recurring_interval_count.years
      else
        raise Exceptions::Payment::InvalidPlan, "Invalid recurring_interval_unit: #{plan.recurring_interval_unit}"
      end
    end

    def create_trial_history(contract:, stripe_record_subscription:)
      membership_plan = contract.current_contract_term.membership_plan
      memberships = membership_plan.memberships
      memberships.each do |membership|
        StripeRecord::TrialHistory.create!(
          tenant_id: contract.tenant_id,
          user: contract.user,
          membership:,
          membership_plan:,
          stripe_record_subscription:,
          fingerprint: get_card_fingerprint(fetch_default_payment_method_or_default_source_of(contract.user)),
          trial_period_days: membership_plan.trial_period_days,
          trial_start: stripe_record_subscription.trial_start,
          trial_end: stripe_record_subscription.trial_end,
        )
      end
    end

    def update_membership_user(contract, next_period_end)
      membership_plan = contract.current_contract_term.membership_plan
      memberships = membership_plan.memberships
      memberships.each do |membership|
        membership_user = Membership::User.find_or_create_by!(
          tenant_id: contract.tenant_id,
          user: contract.user,
          membership_contract: contract,
          membership:,
        )
        membership_user.update!(
          status: 'active',
          expired_at: next_period_end,
        )
      end
    end
  end
end
