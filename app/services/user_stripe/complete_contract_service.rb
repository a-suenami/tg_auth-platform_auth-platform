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
        current_billing_profile.update!(
          status: 'active',
        )
        plan = current_billing_profile.membership_plan
        next unless plan

        # プラン内容に従って有効期限を設定
        if plan.recurrence
          # 定期契約の場合
          # 一回払いの場合
        end
        contract.update!(
          expires_at: calculate_recurring_expiry_date(Time.zone.now, plan),
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
  end
end
