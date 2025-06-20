# typed: false

# ==============================================================================
# app - services - user stripe - create membership subscription service
# ==============================================================================
module UserStripe
  class CreateMembershipSubscriptionService < UserStripe::BaseService
    def execute(user:, stripe_record_price:, stripe_record_subscription: nil)
      # stripe_record_subscription が nil の場合は新規作成
      # stripe_record_subscription が nil でない場合は 3DS などの追加アクションで契約フローを途中離脱した場合
      if stripe_record_subscription.nil?
        stripe_record_subscription = validate_before_subscribing_and_initialize_stripe_subscription(user:, stripe_record_price:)

        fetch_constants

        # TODO: payment_customer_idがpayjpユーザの場合、stripeには投げてはいけない 後で直す
        stripe_subscription_params = {
          customer: user.payment_customer_id,
          items: [
            {
              price: stripe_record_subscription.price.remote_id,
            },
          ],
          # default_tax_rates: [@tax_rate_id],
          payment_behavior: 'default_incomplete',
        }

        # Stripe の API を呼び subscription を作成する
        stripe_subscription = Stripe::Subscription.create(
          stripe_subscription_params,
          stripe_api_key_config,
        )

        # FanApp 側に Stripe の情報を保存
        stripe_record_subscription.status = stripe_subscription.status
        stripe_record_subscription.remote_id = stripe_subscription.id
        stripe_record_subscription.save!

      end
    end

    #   # 3DS などの追加アクションが必要な場合はエラーを返す
    #   stripe_subscription = stripe_record_subscription.refresh!
    #   if stripe_record_subscription.requires_action?
    #     raise Exceptions::Payment::ActionMayBeNeeded.new(stripe_record_subscription:)
    #   end

    #   # 追加アクションが必要ではないのに、 status が active, trialing ではないときは失敗扱いにする
    #   unless stripe_record_subscription.status == 'active' || stripe_record_subscription.status == 'trialing'
    #     # Stripe 上の subscription もキャンセルする
    #     stripe_subscription.cancel

    #     raise Exceptions::Payment::PaymentFailed
    #   end
    # else
    #   # stripe 上で契約が active になっていない場合はエラー
    #   stripe_subscription = stripe_record_subscription.refresh!
    #   raise Exceptions::Payment::ActionMayBeNeeded.new(stripe_record_subscription:) if stripe_record_subscription.requires_action?
    #   raise Exceptions::Payment::PaymentFailed unless stripe_record_subscription.status == 'active' || stripe_record_subscription.status == 'trialing'
    #   raise Exceptions::Payment::AlreadyHaveSubscriptions if stripe_record_subscription.subscription.present?

    #   stripe_record_subscription = evaluate_trial_availability(stripe_record_subscription)
    #   price_options = stripe_record_subscription.price.active_options

    #   # 無料期間は契約実行時刻から「日数 x 24時間」
    #   trial_end = if stripe_record_subscription.trial_status.available?
    #     (Time.zone.now + stripe_record_subscription.price.trial_period_days.days).to_i
    #   end
    # end


    # #
    # # 以降 Stripe 上で subscription が active もしくは trialing の状態の必要で処理行う必要がある
    # #
    # subscription = nil

    # ApplicationRecord.transaction do
    #   # すべて成功したら FanApp 側に subscription を作成し、有料会員に昇格させる
    #   subscription = Subscription.create!(
    #     user_id: user.id,
    #     kind: :membership,
    #     chargeable: stripe_record_subscription,
    #     started_at: Time.zone.at(stripe_subscription.current_period_start),
    #     expires_at: Time.zone.at(stripe_subscription.current_period_end),
    #     trial_end_at: trial_end.present? ? Time.zone.at(trial_end) : nil, # 無料トライアルが無効な場合は nil となる
    #   )

    #   # 万が一 MembershipRenewalHistory, AppStripeTrialHistory の作成に失敗したとしても無視する
    #   suppress(StandardError) do
    #     MembershipRenewalHistories::CreateService.new.execute(user: subscription.user, subscription:)

    #     if stripe_record_subscription.trial_status.available?
    #       AppStripeTrialHistory.create(
    #         price: stripe_record_subscription.price,
    #         user:,
    #         subscription:,
    #         card_fingerprint: get_card_fingerprint(fetch_default_payment_method_or_default_source_of(user)),
    #         trial_period_days: stripe_record_subscription.price.trial_period_days,
    #       )
    #     end
    #   end
    # end

    # #
    # # プランのオプション処理
    # #
    # if price_options.present?
    #   # オプションを紐付けるためのインボイスを作成
    #   app_stripe_invoice = AppStripeInvoice.create!(
    #     stripe_record_subscription:,
    #     user:,
    #     stripe_invoice_id: stripe_subscription.latest_invoice.id,
    #   )

    #   # オプションの紐付け
    #   price_option_items = price_options.map {
    #     { group_id: RequestStore.store[:current_group], app_stripe_invoice_id: app_stripe_invoice.id, price_option_id: _1.id }
    #   }
    #   AppStripePlanOptionItem.import(price_option_items, on_duplicate_key_ignore: true)

    #   # オプションにグッズ付きのものが含まれる場合は配送処理を行う
    #   if price_options.has_active_shopify_product.present?
    #     ShopifyCreateOrderWorker.perform_async(
    #       RequestStore.store[:current_group],
    #       user.id,
    #       price_options.pluck(:app_shopify_product_id).reject(&:nil?),
    #       app_stripe_invoice.class.name,
    #       app_stripe_invoice.id,
    #     )
    #   end
    # end

    # SendgridRegistrationCompletedEmailWorker.perform_async(
    #   RequestStore.store[:current_group],
    #   subscription.id,
    # )

    # stripe_record_subscription
    # end
  end
end
