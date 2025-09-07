# typed: false

module UserStripe
  class CompleteContractService < UserStripe::BaseService
    def execute(contract, stripe_record_subscription)
      ActiveRecord::Base.transaction do
        # Contractのステータスをアクティブに変更
        contract.update!(
          status: 'active',
        )

        current_billing_profile = stripe_record_subscription&.current_billing_profile
        plan = current_billing_profile.membership_plan
        next_period_end = calculate_recurring_expiry_date(Time.zone.now, plan)
        current_billing_profile.update!(
          status: 'active',
          activated_at: Time.zone.now,
          expires_at: next_period_end,
        )
        next unless plan

        # プラン内容に従って有効期限を設定
        if plan.recurrence
          # 定期契約の場合
          # 一回払いの場合
        end
        contract.update!(
          expires_at: next_period_end,
        )

        # Memberships::Userのステータスを有効に変更
        update_membership_user(contract)
        # トライアル履歴を作成
        if stripe_record_subscription.trial_start.present?
          create_trial_history(contract:, stripe_record_subscription:)
        end
        Rails.logger.info "User contract #{contract.id} completed successfully"
      end
    end

    private

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
      membership_plan = contract.current_billing_profile.membership_plan
      memberships = membership_plan.memberships
      memberships.each do |membership|
        Memberships::TrialHistory.create!(
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

    def update_membership_user(contract)
      membership_plan = contract.current_billing_profile.membership_plan
      memberships = membership_plan.memberships
      memberships.each do |membership|
        membership_user = Memberships::User.find_or_create_by!(
          tenant_id: contract.tenant_id,
          user: contract.user,
          membership:,
        )
        # TODO: トライアルの場合、トライアル期限までに設定
        membership_user.update!(
          status: 'active',
          expires_at: calculate_recurring_expiry_date(Time.zone.now, membership_plan),
        )
      end
    end
  end
end
