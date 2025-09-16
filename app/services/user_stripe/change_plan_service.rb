# typed: false

# ==============================================================================
# app/services/memberships/plan_change_service.rb
# ==============================================================================
module UserStripe
  class ChangePlanService < UserStripe::BaseService
    def execute(contract:, new_membership_plan:)
      # プラン変更の検証
      validate_plan_change(contract:, new_membership_plan:)

      # 現在のBillingProfileを取得
      current_billing_profile = contract.current_billing_profile
      raise Exceptions::Payment::NoCurrentBillingProfile unless current_billing_profile

      # Stripeのsubscriptionを取得
      stripe_subscription = current_billing_profile.chargeable
      raise Exceptions::Payment::NoStripeSubscription unless stripe_subscription

      # TODO: プラン変更中ならエラー
      # プラン変更キャンセルAPIも合わせて考える

      # Stripeでプラン変更を実行
      change_stripe_plan(
        stripe_subscription:,
        new_membership_plan:,
        current_billing_profile:,
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

      # 現在のBillingProfileを取得
      current_billing_profile = contract.current_billing_profile
      raise Exceptions::Payment::NoCurrentBillingProfile unless current_billing_profile

      # 支払い方法がクレジットカードでサブスクリプション契約かチェック
      unless current_billing_profile.payment_type == 'credit_card' && current_billing_profile.recurrence?
        raise Exceptions::Payment::NonRecurringSubscription
      end

      # 現在のプランを取得
      current_membership_plan = current_billing_profile.membership_plan



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

    def create_upcoming_billing_profile(contract:, new_membership_plan:, current_billing_profile:)
      # 新しいBillingProfileを作成（phase: upcoming）
      new_billing_profile = Memberships::BillingProfile.new(
        tenant_id: contract.tenant_id,
        user: contract.user,
        membership_plan: new_membership_plan,
        membership_contract: contract,
        payment_type: current_billing_profile.payment_type,
        payment_provider: current_billing_profile.payment_provider,
        external_id: current_billing_profile.external_id, # 同じStripe subscriptionを使用
        chargeable: current_billing_profile.chargeable, # 同じStripe subscriptionを使用
        status: 'pending',
        recurrence: true,
        phase: 'upcoming',
        revision: current_billing_profile.revision + 1,
      )

      new_billing_profile
    end

    def change_stripe_plan(stripe_subscription:, new_membership_plan:, current_billing_profile:, contract:)
      # 新しいプランのStripe Priceを取得
      new_stripe_price = new_membership_plan.plan_payment_methods
        .where(payment_type: 'credit_card')
        .last&.stripe_record_price

      raise Exceptions::Payment::StripePlanChangeError, '新しいプランのStripe価格が見つかりません' unless new_stripe_price

      # プラン変更先が上位プランの場合はproration_behaviorをcreate_prorationsにする
      # プラン変更先が下位プランもしくは請求単位違いの場合はnoneにする
      current_membership_plan = current_billing_profile.membership_plan

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


    def change_plan_immediately(stripe_subscription:, new_stripe_price:, contract:, new_membership_plan:)
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
        contract.update(expires_at: next_period_end)
        # 現在のbilling_profileを取得
        current_billing_profile = stripe_subscription.current_billing_profile
        # 現在のbilling_profileをpastに変更
        current_billing_profile.update!(
          phase: 'closed',
        )

        # 新しいbilling_profileを作成
        create_new_billing_profile_for_plan_change(current_billing_profile, contract, stripe_subscription, new_membership_plan)

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

    def create_new_billing_profile_for_plan_change(current_billing_profile, contract, stripe_subscription, new_membership_plan)
      Memberships::BillingProfile.create!(
        tenant_id: contract.tenant_id,
        user: contract.user,
        membership_plan: new_membership_plan,
        membership_contract: contract,
        chargeable: stripe_subscription,
        payment_type: current_billing_profile.payment_type,
        payment_provider: current_billing_profile.payment_provider,
        phase: 'current',
        activated_at: Time.zone.now,
        expires_at: contract.expires_at,
        status: 'active',
        recurrence: current_billing_profile.recurrence,
        revision: current_billing_profile.revision + 1,
      )
    end

    def change_plan_schedule(stripe_subscription:, new_stripe_price:, contract:, new_membership_plan:)
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

      current_billing_profile = stripe_subscription.current_billing_profile
      # 新しいBillingProfileを作成（phase: upcoming）
      new_billing_profile = create_upcoming_billing_profile(
        membership_contract: contract,
        new_membership_plan:,
        current_billing_profile:,
      )
      # 新しいBillingProfileを保存
      new_billing_profile.save!
    rescue Stripe::StripeError => e
      raise Exceptions::Payment::StripePlanChangeError, "Stripeでのプラン変更に失敗しました: #{e.message}"
    end

    def fetch_or_create_remote_subscription_schedule(stripe_subscription:)
      if stripe_subscription.last_subscription_schedule.present?
        stripe_subscription_schedule = Stripe::SubscriptionSchedule.retrieve(stripe_subscription.last_subscription_schedule.remote_id, stripe_api_key_config)
        # 終了済みのscheduleが紐づいている場合は新しいものに作り替える
        if ['completed', 'canceled', 'released'].include?(stripe_subscription_schedule.status)
          # TODO: subscriptionのscheduleを確認する
          remote_subscription = Stripe::Subscription.retrieve(stripe_subscription.remote_id, stripe_api_key_config)
          if remote_subscription.schedule.present?
            stripe_subscription_schedule = Stripe::SubscriptionSchedule.retrieve(remote_subscription.schedule, stripe_api_key_config)

            if ['completed', 'canceled', 'released'].include?(stripe_subscription_schedule.status)
              stripe_subscription_schedule = Stripe::SubscriptionSchedule.create({
                from_subscription: stripe_subscription.remote_id,
              }, stripe_api_key_config,)
            end
          else
            stripe_subscription_schedule = Stripe::SubscriptionSchedule.create({
              from_subscription: stripe_subscription.remote_id,
            }, stripe_api_key_config,)
          end

          StripeRecord::SubscriptionSchedule.create(
            tenant_id: stripe_subscription.tenant_id,
            user_id: stripe_subscription.user_id,
            subscription_id: stripe_subscription.id,
            remote_id: stripe_subscription_schedule.id,
            status: stripe_subscription_schedule.status,
            phases: stripe_subscription_schedule.phases,
          )
        end
      else
        begin
          Stripe::SubscriptionSchedule.create({
            from_subscription: stripe_subscription.remote_id,
          }, stripe_api_key_config,)
        rescue Stripe::InvalidRequestError => e
          # scheduleは複数作成できないため、すでに存在しているとエラーする恐れがある。
          # その場合、Subscriptionを再取得し既存のスケジュールを利用する
          remote_subscription = Stripe::Subscription.retrieve(stripe_subscription.remote_id, stripe_api_key_config)
          if remote_subscription.schedule.present?
            remote_subscription.schedule
            Stripe::SubscriptionSchedule.retrieve(remote_subscription.schedule, stripe_api_key_config)
          else
            raise e
          end
        end
        StripeRecord::SubscriptionSchedule.create(
          tenant_id: stripe_subscription.tenant_id,
          user_id: stripe_subscription.user_id,
          subscription_id: stripe_subscription.id,
          remote_id: stripe_subscription_schedule.id,
          status: stripe_subscription_schedule.status,
          phases: stripe_subscription_schedule.phases,
        )

      end
      stripe_subscription_schedule
    end
  end
end
