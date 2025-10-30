# typed: false

# ==============================================================================
# app - services - user stripe - create membership subscription service
# ==============================================================================
module UserStripe
  class CreateMembershipSubscriptionService < UserStripe::BaseService
    def execute(user:, membership_plan:, off_session: false)
      stripe_record_price = find_stripe_record_price(membership_plan)
      stripe_record_subscription = initialize_stripe_subscription(user, membership_plan, stripe_record_price)

      fetch_constants

      stripe_subscription = create_stripe_subscription(user, membership_plan, stripe_record_subscription, off_session)

      if off_session && stripe_subscription.status != 'active'
        raise Exceptions::Payment::Stripe::StripeError, "Stripeでの契約に失敗しました: #{stripe_subscription.status}"
      end

      ActiveRecord::Base.transaction do
        update_stripe_record_subscription(stripe_record_subscription, stripe_subscription)
        chargeable = save_payment_intent_or_setup_intent(stripe_subscription, user, stripe_record_subscription)

        contract = create_contract(user:, stripe_record_subscription:, membership_plan:, chargeable:, off_session:)
        create_membership_users(user:, membership_plan:, contract:, off_session:)

        contract
      end
    rescue Stripe::StripeError => e
      Sentry.capture_exception(e)
      raise Exceptions::Payment::Stripe::StripeError, "Stripeでの契約に失敗しました: #{e.message}"
    end

    private

    def find_stripe_record_price(membership_plan)
      membership_plan.plan_payment_methods.where(payment_type: 'credit_card').last.stripe_record_price
    end

    def initialize_stripe_subscription(user, membership_plan, stripe_record_price)
      # stripe_record_subscription が nil の場合は新規作成
      # stripe_record_subscription が nil でない場合は 3DS などの追加アクションで契約フローを途中離脱した場合
      validate_before_subscribing_and_initialize_stripe_subscription(
        user:,
        membership_plan:,
        stripe_record_price:,
      )
    end

    def create_stripe_subscription(user, membership_plan, stripe_record_subscription, off_session)
      # TODO: payment_customer_idがpayjpユーザの場合、stripeには投げてはいけない 後で直す
      stripe_subscription_params = build_stripe_subscription_params(user, membership_plan, stripe_record_subscription, off_session)

      # Stripe の API を呼び subscription を作成する
      Stripe::Subscription.create(stripe_subscription_params, stripe_api_key_config)
    end

    def build_stripe_subscription_params(user, membership_plan, stripe_record_subscription, off_session)
      params = if off_session
        {
          customer: user.payment_customer_id,
          items: [{ price: stripe_record_subscription.price.remote_id }],
          # default_tax_rates: [@tax_rate_id],
          payment_behavior: 'error_if_incomplete',
          collection_method: 'charge_automatically',
          payment_settings: {
            save_default_payment_method: 'on_subscription',
            payment_method_types: ['card'],
            payment_method_options: {
              card: { request_three_d_secure: 'automatic' },
            },
          },
          expand: ['latest_invoice.confirmation_secret', 'pending_setup_intent'],
        }
      else
        {
          customer: user.payment_customer_id,
          items: [{ price: stripe_record_subscription.price.remote_id }],
          # default_tax_rates: [@tax_rate_id],
          payment_behavior: 'default_incomplete',
          collection_method: 'charge_automatically',
          payment_settings: {
            save_default_payment_method: 'on_subscription',
            payment_method_types: ['card'],
          },
          expand: ['latest_invoice.confirmation_secret', 'pending_setup_intent'],
        }
      end

      if membership_plan.trial_period_days.positive? && check_trial_availability(user:, membership_plan:)
        params[:trial_period_days] = membership_plan.trial_period_days
      end

      params
    end

    def update_stripe_record_subscription(stripe_record_subscription, stripe_subscription)
      # IDP 側に Stripe の情報を保存
      stripe_record_subscription.status = stripe_subscription.status
      stripe_record_subscription.remote_id = stripe_subscription.id
      stripe_record_subscription.trial_end = stripe_subscription.trial_end
      stripe_record_subscription.trial_start = stripe_subscription.trial_start

      update_period_dates(stripe_record_subscription, stripe_subscription)
      stripe_record_subscription.save!
    end

    def update_period_dates(stripe_record_subscription, stripe_subscription)
      # 現在の請求期間の開始日時と終了日時を保存
      if stripe_subscription.try(:current_period_start)
        stripe_record_subscription.current_period_start = Time.zone.at(stripe_subscription.current_period_start)
        stripe_record_subscription.current_period_end = Time.zone.at(stripe_subscription.current_period_end)
      elsif stripe_subscription&.items&.data&.first.try(:current_period_start)
        first_item = stripe_subscription.items.data.first
        stripe_record_subscription.current_period_start = Time.zone.at(first_item.current_period_start)
        stripe_record_subscription.current_period_end = Time.zone.at(first_item.current_period_end)
      end
    end

    def save_payment_intent_or_setup_intent(stripe_subscription, user, stripe_record_subscription)
      latest_invoice = Stripe::Invoice.retrieve({ id: stripe_subscription.latest_invoice.id, expand: ['confirmation_secret', 'payments.data.payment.payment_intent'] }, stripe_api_key_config)

      invoice_record = StripeRecord::Invoice.find_or_create_by!(remote_id: latest_invoice.id) do |record|
        record.user = user
        record.tenant_id = user.tenant_id
        record.remote_id = latest_invoice.id
        record.status = latest_invoice.status
        record.payment_source = stripe_record_subscription
        record.confirmation_secret = latest_invoice&.confirmation_secret&.client_secret
        record.confirmation_secret_type = 'payment_intent' if latest_invoice&.confirmation_secret&.client_secret.present?
      end

      if latest_invoice.try(:confirmation_secret) && latest_invoice.confirmation_secret.present?
        # confirmation_secret が存在する場合 (PaymentIntentベース)
        payment_intent = latest_invoice.payments.data.first.payment.payment_intent

        # Stripe::PaymentIntent -> StripeRecord::PaymentIntent へ反映
        stripe_record_payment_intent = StripeRecord::PaymentIntent.find_or_initialize_by(remote_id: payment_intent.id)
        stripe_record_payment_intent.user = user
        stripe_record_payment_intent.tenant_id = user.tenant_id
        stripe_record_payment_intent.invoice = invoice_record
        stripe_record_payment_intent.assign_remote_attributes(payment_intent)
        # assign_remote_attributes で埋まらない分を補完
        stripe_record_payment_intent.client_secret = payment_intent&.client_secret
        stripe_record_payment_intent.confirmation_method = payment_intent.confirmation_method
        stripe_record_payment_intent.capture_method = payment_intent.capture_method
        stripe_record_payment_intent.api_key_account = Tenant.current&.tenant_stripe_account&.stripe_account
        stripe_record_payment_intent.save!

        stripe_record_payment_intent
      elsif stripe_subscription.pending_setup_intent
        # SetupIntent が存在する場合
        setup_intent = stripe_subscription.pending_setup_intent
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
        stripe_record_setup_intent
      else
        raise Exceptions::Payment::IntentNotFound, 'PaymentIntent or SetupIntent not found'
      end
    end

    def create_contract(user:, stripe_record_subscription:, membership_plan:, chargeable:, off_session:)
      # 即時契約なのでステータスはactiveにする
      if off_session
        contract = Membership::Contract.create!(
          user:,
          status: 'active',
        )
        # transactions作成
        Payment::Transaction.create!(
          user:,
          membership_contract: contract,
          payment_type: 'credit_card',
          payment_provider: 'stripe',
          chargeable: chargeable,
          status: 'active',
          recurrence: true,
        )
        Payment::Subscription.create!(
          user:,
          membership_contract: contract,
          subscribable: stripe_record_subscription,
        )
        Membership::ContractTerm.create!(
          user:,
          membership_contract: contract,
          membership_plan:,
          payment_type: 'credit_card',
          start_at: Time.zone.now,
          end_at: stripe_record_subscription.current_period_end,
          status: 'current',
        )
      else
        contract = Membership::Contract.create!(
          user:,
          status: 'pending',
        )
        # transactions作成
        Payment::Transaction.create!(
          user:,
          membership_contract: contract,
          payment_type: 'credit_card',
          payment_provider: 'stripe',
          chargeable: chargeable,
          status: 'pending',
          recurrence: true,
        )
        Payment::Subscription.create!(
          user:,
          membership_contract: contract,
          subscribable: stripe_record_subscription,
        )
        Membership::ContractTerm.create!(
          user:,
          membership_contract: contract,
          membership_plan:,
          payment_type: 'credit_card',
          status: 'current',
          start_at: Time.zone.now,
          end_at: stripe_record_subscription.current_period_end,
        )
      end

      contract
    end

    def create_membership_users(user:, membership_plan:, contract:, off_session:)
      membership_plan.memberships.each do |membership|
        if off_session
          Membership::User.create!(
            user:,
            membership:,
            status: 'active',
            activated_at: Time.zone.now,
            expired_at: contract.current_contract_term.end_at,
            membership_contract: contract,
          )
        else
          Membership::User.create!(
            user:,
            membership:,
            status: 'pending',
            membership_contract: contract,
          )
        end
      end
    end

    # MEMO: トライアルの制限方法は別要望があるかもだが、とりあえずメンバーシップごとクレジットカードfingerprintの制限にする
    def check_trial_availability(user:, membership_plan:)
      # トライアル履歴が存在する場合はトライアルを利用できない
      memberships = membership_plan.memberships
      if memberships.any? && StripeRecord::TrialHistory.exists?(membership: memberships, fingerprint: get_card_fingerprint(fetch_default_payment_method_or_default_source_of(user)))
        return false
      end

      true
    end

  end
end
