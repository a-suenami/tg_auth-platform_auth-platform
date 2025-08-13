# typed: false

# ==============================================================================
# app/services/memberships/plan_change_service.rb
# ==============================================================================
module Memberships
  class PlanChangeService < Memberships::BaseService
    def execute(user_contract:, new_membership_plan:)
      # プラン変更の検証
      validate_plan_change(user_contract:, new_membership_plan:)

      # 現在のBillingProfileを取得
      current_billing_profile = user_contract.current_billing_profile
      raise Exceptions::Payment::NoCurrentBillingProfile unless current_billing_profile

      # Stripeのsubscriptionを取得
      stripe_subscription = current_billing_profile.chargeable
      raise Exceptions::Payment::NoStripeSubscription unless stripe_subscription

      ActiveRecord::Base.transaction do
        # 新しいBillingProfileを作成（phase: upcoming）
        new_billing_profile = create_upcoming_billing_profile(
          user_contract:,
          new_membership_plan:,
          current_billing_profile:,
        )

        # Stripeでプラン変更を実行
        change_stripe_plan(
          stripe_subscription:,
          new_membership_plan:,
          current_billing_profile:,
        )

        # 新しいBillingProfileを保存
        new_billing_profile.save!

        user_contract
      end
    end

    private

    def validate_plan_change(user_contract:, new_membership_plan:)
      # user_contractが完了済みかチェック
      unless user_contract.status == 'active'
        raise Exceptions::Payment::UserContractNotActive
      end

      # 現在のBillingProfileを取得
      current_billing_profile = user_contract.current_billing_profile
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

      (current_tiers & new_tiers).empty?
    end

    def different_billing_cycle?(current_membership_plan:, new_membership_plan:)
      # 有効期間が異なる場合（月額 vs 年額）
      current_membership_plan.validity_period != new_membership_plan.validity_period
    end

    def create_upcoming_billing_profile(user_contract:, new_membership_plan:, current_billing_profile:)
      # 新しいBillingProfileを作成（phase: upcoming）
      new_billing_profile = Memberships::BillingProfile.new(
        tenant_id: user_contract.tenant_id,
        user: user_contract.user,
        membership_plan: new_membership_plan,
        user_contract:,
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

    def change_stripe_plan(stripe_subscription:, new_membership_plan:, current_billing_profile:)
      # 新しいプランのStripe Priceを取得
      new_stripe_price = new_membership_plan.plan_payment_methods
        .where(payment_type: 'credit_card')
        .last&.stripe_record_price

      raise Exceptions::Payment::StripePlanChangeError, '新しいプランのStripe価格が見つかりません' unless new_stripe_price

      # Stripeのsubscription itemを取得
      subscription_item = stripe_subscription.subscription_items.first
      raise Exceptions::Payment::StripePlanChangeError, 'Stripeのサブスクリプションアイテムが見つかりません' unless subscription_item

      # プラン変更先が上位プランの場合はproration_behaviorをcreate_prorationsにする
      # プラン変更先が下位プランもしくは請求単位違いの場合はnoneにする
      current_membership_plan = current_billing_profile.membership_plan

      if hierarchical_plan_change?(current_membership_plan:, new_membership_plan:)
        current_tiers = current_membership_plan.memberships.pluck(:tier)
        new_tiers = new_membership_plan.memberships.pluck(:tier)
        if current_tiers.sum > new_tiers.sum
          change_plan_immediately(stripe_subscription:, subscription_item:, new_stripe_price:)
        else
          change_plan_schedule(stripe_subscription:, subscription_item:, new_stripe_price:)
        end
      else
        change_plan_schedule(stripe_subscription:, subscription_item:, new_stripe_price:)
      end
    end


    def change_plan_immediately(stripe_subscription:, subscription_item:, new_stripe_price:)
      Stripe::Subscription.update(
        stripe_subscription.remote_id,
        {
          items: [
            {
              id: subscription_item.remote_id,
              price: new_stripe_price.remote_id,
            },
          ],
          proration_behavior: 'create_prorations',
        }, stripe_api_key_config,
      )
    end

    def change_plan_schedule(stripe_subscription:, subscription_item:, new_stripe_price:)
      stripe_subscription_schedule = Stripe::SubscriptionSchedule.create({
        from_subscription: stripe_subscription.remote_id,
      }, stripe_api_key_config,)

      Stripe::SubscriptionSchedule.update(
        stripe_subscription_schedule.id,
        {
          end_behavior: 'release',
          phases: [
            {
              start_date: stripe_subscription_schedule.current_phase.start_date,
              items: [{ price: subscription_item.price.remote_id }],
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
    rescue Stripe::StripeError => e
      raise Exceptions::Payment::StripePlanChangeError, "Stripeでのプラン変更に失敗しました: #{e.message}"
    end
  end
end
