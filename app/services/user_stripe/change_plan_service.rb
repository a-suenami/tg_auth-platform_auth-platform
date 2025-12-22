# typed: false

# ==============================================================================
# app/services/memberships/plan_change_service.rb
# ==============================================================================
module UserStripe
  class ChangePlanService < UserStripe::BaseService
    def execute(contract:, new_membership_plan:)
      # プラン変更の検証
      validate_plan_change(contract:, new_membership_plan:)

      # TODO: PaymentTransactionをチェック
      # TODO: ContractTermをチェック
      current_contract_term = contract.current_contract_term
      raise Exceptions::Payment::NoCurrentContractTerm unless current_contract_term

      # Stripeのsubscriptionを取得
      stripe_subscription = contract.payment_subscription.chargeable
      raise Exceptions::Payment::NoStripeSubscription if stripe_subscription.blank? || !stripe_subscription.is_a?(StripeRecord::Subscription)

      # TODO: プラン変更中ならエラー
      # プラン変更キャンセルAPIも合わせて考える

      # Stripeでプラン変更を実行
      change_stripe_plan(
        stripe_subscription:,
        new_membership_plan:,
        current_contract_term:,
        contract:,
      )

      contract
    end

    private

    def validate_plan_change(contract:, new_membership_plan:)
      # contractが完了済みかチェック
      unless contract.status == 'active'
        raise Exceptions::Payment::ContractNotActive
      end

      # TODO: PaymentSubscriptionをチェック
      # TODO: ContractTermをチェック


      current_membership_plan = contract.current_contract_term.membership_plan


      # 変更可能なプランかチェック
      changeable_plan?(current_membership_plan:, new_membership_plan:)
    end

    def same_membership?(current_membership_plan:, new_membership_plan:)
      current_membership_ids = current_membership_plan.memberships.pluck(:id).sort
      new_membership_ids = new_membership_plan.memberships.pluck(:id).sort
      current_membership_ids == new_membership_ids
    end

    def changeable_plan?(current_membership_plan:, new_membership_plan:)
      # 同じプランは変更不可
      return raise Exceptions::Payment::UnchangeablePlan if current_membership_plan.id == new_membership_plan.id

      # 段階的プランの上位/下位プランかチェック
      if hierarchical_plan_change?(current_membership_plan:, new_membership_plan:)
        return true
      else
        # 同じメンバーシップの契約プランかチェック
        unless same_membership?(current_membership_plan:, new_membership_plan:)
          raise Exceptions::Payment::DifferentMembershipPlan
        end
      end

      # 支払いサイクルが異なるかチェック
      if different_billing_cycle?(current_membership_plan:, new_membership_plan:)
        return true
      end

      raise Exceptions::Payment::UnchangeablePlan
    end

    def hierarchical_plan_change?(current_membership_plan:, new_membership_plan:)
      # 同じMembershipGroupに属するプランで、tierが異なる場合
      current_groups = current_membership_plan.memberships.pluck('membership_group_id')
      new_groups = new_membership_plan.memberships.pluck('membership_group_id')

      # 共通のグループがある場合
      common_groups = current_groups & new_groups
      return false if common_groups.empty?

      # tierが異なる場合（上位/下位プラン）
      current_tiers = current_membership_plan.memberships.where(membership_group_id: common_groups).pluck(:tier)
      new_tiers = new_membership_plan.memberships.where(membership_group_id: common_groups).pluck(:tier)

      !current_tiers.intersect?(new_tiers)
    end

    def different_billing_cycle?(current_membership_plan:, new_membership_plan:)
      # 課金サイクルが異なる場合（期間の単位や数が異なる）
      current_membership_plan.recurring_interval_unit != new_membership_plan.recurring_interval_unit ||
        current_membership_plan.recurring_interval_count != new_membership_plan.recurring_interval_count
    end


    def change_stripe_plan(stripe_subscription:, new_membership_plan:, current_contract_term:, contract:)
      # 新しいプランのStripe Priceを取得
      new_stripe_price = new_membership_plan.plan_payment_methods
        .where(payment_type: 'credit_card')
        .last&.stripe_record_price

      raise Exceptions::Payment::StripePlanChangeError, '新しいプランのStripe価格が見つかりません' unless new_stripe_price

      # プラン変更先が上位プランの場合はproration_behaviorをcreate_prorationsにする
      # プラン変更先が下位プランもしくは請求単位違いの場合はnoneにする
      current_membership_plan = current_contract_term.membership_plan

      if hierarchical_plan_change?(current_membership_plan:, new_membership_plan:)
        current_tiers = current_membership_plan.memberships.pluck(:tier)
        new_tiers = new_membership_plan.memberships.pluck(:tier)
        if current_tiers.sum > new_tiers.sum
          change_plan_immediately(stripe_subscription:, new_stripe_price:, contract:, new_membership_plan:)
        else
          change_plan_schedule(stripe_subscription:, new_stripe_price:, contract:, new_membership_plan:)
        end
      else
        change_plan_schedule(stripe_subscription:, new_stripe_price:, contract:, new_membership_plan:)
      end
    end


    def change_plan_immediately(stripe_subscription:, new_stripe_price:, contract:, _new_membership_plan:)
      # # subscription schedule中の契約を即時プラン変更させてはいけない。現在のsubscriptionのみ即時変更されて、scheduleが残る
      # if stripe_subscription.last_subscription_schedule.present?
      #   # 更新がスケジュールされている場合は、スケジュールを破棄
      #   subscription_schedule = Stripe::SubscriptionSchedule.retrieve(stripe_subscription.last_subscription_schedule.remote_id, stripe_api_key_config)
      #   if subscription_schedule.status == 'active'
      #     subscription_schedule.release
      #   end
      # end

      # # 最新のSubscriptionItemを取得
      # # TODO: 複数SubscriptionItemがある場合の想定(グッツ付きプランとか？)
      # subscription_items = Stripe::SubscriptionItem.list({
      #   limit: 10,
      #   subscription: stripe_subscription.remote_id,
      # }, stripe_api_key_config,)
      # first_subscription_item = subscription_items.data.first

      # Stripe::Subscription.update(
      #   stripe_subscription.remote_id,
      #   {
      #     items: [
      #       {
      #         id: first_subscription_item.id,
      #         price: new_stripe_price.remote_id,
      #       },
      #     ],
      #     proration_behavior: 'always_invoice',
      #   }, stripe_api_key_config,
      # )

      # TODO: 有効なスケジュールがある場合にプランを即時反映で上書きはできなそう

      ActiveRecord::Base.transaction do
        stripe_subscription_schedule = fetch_or_create_remote_subscription_schedule(stripe_subscription:)

        remote_subscription_schedule = Stripe::SubscriptionSchedule.update(
          stripe_subscription_schedule.id,
          {
            end_behavior: 'release',
            phases: [
              {
                start_date: stripe_subscription_schedule.current_phase.start_date,
                items: [{ price: stripe_subscription.price.remote_id }],
                end_date: 'now',
              },
              {
                # 次回更新時に新しいプランに変更
                start_date: 'now',
                items: [{ price: new_stripe_price.remote_id }],
                proration_behavior: 'always_invoice',
                # start_date は前の phase の end_date と自動連結されるので省略可能
              },
            ],
          }, stripe_api_key_config,
        )

        # Contractの期限更新
        next_period_end = Time.zone.at(remote_subscription_schedule.phases.first.end_date)
        contract.update(expired_at: next_period_end)
        current_contract_term = contract.current_contract_term
        current_contract_term.update!(
          status: 'closed',
        )
        Membership::ContractTerm.create!(
          status: 'active',
          phase: 'current',
          payment_type: 'credit_card',
          expires_at: next_period_end,
          activated_at: Time.zone.now,
        )
        # stripe_subscriptionの更新
        stripe_subscription.update!(
          current_period_start: Time.zone.now,
          current_period_end: next_period_end,
          price: new_stripe_price,
          status: 'active',
        )
      end
    rescue Stripe::StripeError => e
      raise Exceptions::Payment::StripePlanChangeError, "Stripeでのプラン変更に失敗しました: #{e.message}"
    end

    def change_plan_schedule(stripe_subscription:, new_stripe_price:, _contract:, _new_membership_plan:)
      stripe_subscription_schedule = fetch_or_create_remote_subscription_schedule(stripe_subscription:)

      Stripe::SubscriptionSchedule.update(
        stripe_subscription_schedule.id,
        {
          end_behavior: 'release',
          phases: [
            {
              start_date: stripe_subscription_schedule.current_phase.start_date,
              items: [{ price: stripe_subscription.price.remote_id }],
              end_date: stripe_subscription.current_period_end.to_i,
            },
            {
              # 次回更新時に新しいプランに変更
              start_date: stripe_subscription.current_period_end.to_i,
              items: [{ price: new_stripe_price.remote_id }],
              # start_date は前の phase の end_date と自動連結されるので省略可能
            },
          ],
        }, stripe_api_key_config,
      )

      # TODO: ContractTermの更新
    rescue Stripe::StripeError => e
      raise Exceptions::Payment::StripePlanChangeError, "Stripeでのプラン変更に失敗しました: #{e.message}"
    end

    def fetch_or_create_remote_subscription_schedule(stripe_subscription:)
      if stripe_subscription.last_subscription_schedule.present?
        handle_existing_schedule(stripe_subscription)
      else
        create_new_schedule(stripe_subscription)
      end
    end


    def handle_existing_schedule(stripe_subscription)
      stripe_subscription_schedule = Stripe::SubscriptionSchedule.retrieve(
        stripe_subscription.last_subscription_schedule.remote_id,
        stripe_api_key_config,
      )

      if schedule_completed?(stripe_subscription_schedule)
        create_schedule_from_subscription(stripe_subscription)
      else
        stripe_subscription_schedule
      end
    end

    def create_new_schedule(stripe_subscription)
      begin
        stripe_subscription_schedule = Stripe::SubscriptionSchedule.create({
          from_subscription: stripe_subscription.remote_id,
        }, stripe_api_key_config,)
      rescue Stripe::InvalidRequestError => e
        stripe_subscription_schedule = handle_schedule_creation_error(stripe_subscription, e)
      end

      save_subscription_schedule(stripe_subscription, stripe_subscription_schedule)
      stripe_subscription_schedule
    end

    def schedule_completed?(schedule)
      ['completed', 'canceled', 'released'].include?(schedule.status)
    end

    def create_schedule_from_subscription(stripe_subscription)
      remote_subscription = Stripe::Subscription.retrieve(stripe_subscription.remote_id, stripe_api_key_config)

      if remote_subscription.schedule.present?
        stripe_subscription_schedule = Stripe::SubscriptionSchedule.retrieve(
          remote_subscription.schedule,
          stripe_api_key_config,
        )

        if schedule_completed?(stripe_subscription_schedule)
          stripe_subscription_schedule = Stripe::SubscriptionSchedule.create({
            from_subscription: stripe_subscription.remote_id,
          }, stripe_api_key_config,)
        end
      else
        stripe_subscription_schedule = Stripe::SubscriptionSchedule.create({
          from_subscription: stripe_subscription.remote_id,
        }, stripe_api_key_config,)
      end

      save_subscription_schedule(stripe_subscription, stripe_subscription_schedule)
      stripe_subscription_schedule
    end

    def handle_schedule_creation_error(stripe_subscription, error)
      # scheduleは複数作成できないため、すでに存在しているとエラーする恐れがある。
      # その場合、Subscriptionを再取得し既存のスケジュールを利用する
      remote_subscription = Stripe::Subscription.retrieve(stripe_subscription.remote_id, stripe_api_key_config)

      if remote_subscription.schedule.present?
        Stripe::SubscriptionSchedule.retrieve(remote_subscription.schedule, stripe_api_key_config)
      else
        raise error
      end
    end

    def save_subscription_schedule(stripe_subscription, stripe_subscription_schedule)
      StripeRecord::SubscriptionSchedule.create(
        tenant_id: stripe_subscription.tenant_id,
        user_id: stripe_subscription.user_id,
        subscription_id: stripe_subscription.id,
        remote_id: stripe_subscription_schedule.id,
        status: stripe_subscription_schedule.status,
        phases: stripe_subscription_schedule.phases,
      )
    end
  end
end
