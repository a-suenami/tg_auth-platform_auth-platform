# typed: false

# ==============================================================================
# app - services - user stripe - create membership subscription service
# ==============================================================================
module UserStripe
  class CreateMembershipSubscriptionService < UserStripe::BaseService
    def execute(user:, membership_plan:)
      stripe_record_price = membership_plan.plan_payment_methods.where(payment_type: 'credit_card').last.stripe_record_price
      # stripe_record_subscription が nil の場合は新規作成
      # stripe_record_subscription が nil でない場合は 3DS などの追加アクションで契約フローを途中離脱した場合
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
        collection_method: 'charge_automatically',
        payment_settings: {
          save_default_payment_method: 'on_subscription',
          payment_method_types: ['card'],
        },
        expand: ['latest_invoice.confirmation_secret', 'pending_setup_intent'],
      }

      if membership_plan.trial_period_days.positive? && check_trial_availability(user:, membership_plan:)
        stripe_subscription_params[:trial_period_days] = membership_plan.trial_period_days
      end

      # Stripe の API を呼び subscription を作成する
      stripe_subscription = Stripe::Subscription.create(
        stripe_subscription_params,
      stripe_api_key_config,
      )

      contract = nil

      ActiveRecord::Base.transaction do
        # IDP 側に Stripe の情報を保存
        stripe_record_subscription.status = stripe_subscription.status
        stripe_record_subscription.remote_id = stripe_subscription.id
        stripe_record_subscription.trial_end = stripe_subscription.trial_end
        stripe_record_subscription.trial_start = stripe_subscription.trial_start
        # 現在の請求期間の開始日時と終了日時を保存
        if  stripe_subscription.try(:current_period_start)
          stripe_record_subscription.current_period_start = Time.zone.at(stripe_subscription.current_period_start)
          stripe_record_subscription.current_period_end = Time.zone.at(stripe_subscription.current_period_end)
        elsif stripe_subscription&.items&.data&.first.try(:current_period_start)
          stripe_record_subscription.current_period_start = Time.zone.at(stripe_subscription.items.data.first.current_period_start)
          stripe_record_subscription.current_period_end = Time.zone.at(stripe_subscription.items.data.first.current_period_end)
        end
        stripe_record_subscription.save!

        # SubscriptionItems を保存
        save_subscription_items(stripe_subscription, user, stripe_record_subscription)

        # PaymentIntent(confirmation_secret) または SetupIntent を保存
        save_payment_intent_or_setup_intent(stripe_subscription, user, stripe_record_subscription)

        contract = create_contract(user:, stripe_record_subscription:, membership_plan:)
        create_membership_users(user:, membership_plan:, contract:)
      end
      contract
    end

    private

    def save_subscription_items(stripe_subscription, user, stripe_record_subscription)
      # Stripe::Subscription.createのレスポンスからsubscription_itemsを取得
      stripe_subscription.items.data.each do |stripe_subscription_item|
        # Stripeのprice_idからStripeRecord::Priceを検索
        stripe_record_price = StripeRecord::Price.find_by!(remote_id: stripe_subscription_item.price.id)

        StripeRecord::SubscriptionItem.find_or_create_by!(remote_id: stripe_subscription_item.id) do |record|
          record.tenant_id = user.tenant_id
          record.subscription = stripe_record_subscription
          record.price = stripe_record_price
          record.remote_id = stripe_subscription_item.id
          record.quantity = stripe_subscription_item.quantity
          record.billing_thresholds = stripe_subscription_item.billing_thresholds
          record.current_period_start = stripe_subscription_item.current_period_start
          record.current_period_end = stripe_subscription_item.current_period_end
          record.discounts = stripe_subscription_item.discounts
          record.metadata = stripe_subscription_item.metadata
          record.tax_rates = stripe_subscription_item.tax_rates
        end
      end
    end

    def save_payment_intent_or_setup_intent(stripe_subscription, user, stripe_record_subscription)
      latest_invoice = Stripe::Invoice.retrieve({ id: stripe_subscription.latest_invoice.id, expand: ['confirmation_secret'] }, stripe_api_key_config)

      stripe_record_invoice = StripeRecord::Invoice.find_or_create_by!(remote_id: latest_invoice.id) do |record|
        record.user = user
        record.tenant_id = user.tenant_id
        record.remote_id = latest_invoice.id
        record.status = latest_invoice.status
        record.chargeable = stripe_record_subscription
        record.confirmation_secret = latest_invoice&.confirmation_secret&.client_secret
        record.confirmation_secret_type = 'payment_intent' if latest_invoice&.confirmation_secret&.client_secret.present?
      end

      if latest_invoice.try(:confirmation_secret)
        # confirmation_secret が存在する場合
        confirmation_secret = latest_invoice.confirmation_secret

      elsif stripe_subscription.pending_setup_intent
        # SetupIntent が存在する場合
        setup_intent_remote_id = stripe_subscription.pending_setup_intent
        setup_intent = Stripe::SetupIntent.retrieve(setup_intent_remote_id, stripe_api_key_config)
        stripe_record_setup_intent = StripeRecord::SetupIntent.find_or_create_by!(remote_id: setup_intent.id) do |record|
          record.user = user
          record.tenant_id = user.tenant_id
          record.status = setup_intent.status
          record.usage = setup_intent.usage
          record.client_secret = setup_intent.client_secret
          record.api_key_account = Tenant.current&.tenant_stripe_account&.stripe_account
        end
        stripe_record_subscription.pending_setup_intent = stripe_record_setup_intent
        stripe_record_subscription.save!
      else
        raise Exceptions::Payment::IntentNotFound, 'PaymentIntent or SetupIntent not found'
      end
    end

    def create_contract(user:, stripe_record_subscription:, membership_plan:)
      contract = Memberships::Contract.create!(
        user:,
        status: 'pending',
      )
      # billing_profiles作成
      Memberships::BillingProfile.create!(
        user:,
        membership_plan:,
        contract:,
        payment_type: 'credit_card',
        payment_provider: 'stripe',
        external_id: stripe_record_subscription.remote_id,
        chargeable: stripe_record_subscription,
        status: 'pending',
        recurrence: true,
      )

      contract
    end

    def create_membership_users(user:, membership_plan:, contract:)
      membership_plan.memberships.each do |membership|
        Memberships::User.create!(
          user:,
          membership:,
          status: 'pending',
          membership_contract: contract,
        )
      end
    end

    # MEMO: トライアルの制限方法は別要望があるかもだが、とりあえずメンバーシップごとクレジットカードfingerprintの制限にする
    def check_trial_availability(user:, membership_plan:)
      # トライアル履歴が存在する場合はトライアルを利用できない
      memberships = membership_plan.memberships
      if memberships.any? && Memberships::TrialHistory.exists?(membership: memberships, fingerprint: get_card_fingerprint(fetch_default_payment_method_or_default_source_of(user)))
        return false
      end

      true
    end

    def create_trial_history(user:, membership_plan:, stripe_record_subscription:)
      memberships = membership_plan.memberships
      memberships.each do |membership|
        Memberships::TrialHistory.create!(
          tenant_id: user.tenant_id,
          user:,
          membership:,
          membership_plan:,
          stripe_record_subscription:,
          trial_started_at: Time.zone.now,
          fingerprint: get_card_fingerprint(fetch_default_payment_method_or_default_source_of(user)),
          trial_period_days: membership_plan.trial_period_days,
        )
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
