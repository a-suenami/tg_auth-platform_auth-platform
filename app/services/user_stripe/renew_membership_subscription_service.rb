# typed: false

# ==============================================================================
# Stripe Subscription自動更新処理サービス
# ==============================================================================
# 想定されるケース:
#
# 1. 自動更新期限前
#    - Stripe状態: subscription.current_period_end がまだ未来
#    - 処理: fetch_stripe_snapshot!で期間が進んでいないため、nilを返してスキップ
#    - 判定: current_period_end + 1.hour < current_period_end が false
#    - 結果: 何もしない（次回実行時に再チェック）
#
# 2. 自動更新期限後(決済未完了)
#    - Stripe状態: latest_invoice.status_transitions.finalized_at が nil（未finalize）
#    - 処理: 猶予期間内の場合、:graceを返して何もしない
#    - 判定: finalized_at.blank? && grace期間内
#    - 結果: result.kind == :grace → 何もしない（猶予期間内のため待機）
#
# 3. 自動更新期限後(決済完了)
#    - Stripe状態: latest_invoice.status == 'paid' または payment_intent.status == 'succeeded'
#    - 処理: persist_paid!で契約・サブスクリプション・メンバーシップを更新
#    - 判定: result.kind == :paid
#    - 結果: 契約をactive、期限を更新、PaymentTransaction作成、メール送信
#
# 4. 自動更新期限後(past_due、決済失敗)
#    - Stripe状態: subscription.status == 'past_due' または invoice.status == 'open'
#    - 処理: persist_past_due!で何もしない（active維持）
#    - 判定: result.kind == :past_due
#    - 結果: 何もしない（active維持、次回再試行）
#
# 5. 自動更新期限後(決済期限切れ、canceled)
#    - Stripe状態: subscription.status == 'canceled'/'unpaid'/'incomplete_expired'
#    - 処理: persist_canceled!で契約・メンバーシップをclosedに更新
#    - 判定: result.kind == :canceled
#    - 結果: 契約をcanceled、メンバーシップをclosed、ContractTermをclosedに更新
#
# 6. 自動更新キャンセル済み
#    - Stripe状態: subscription.status == 'canceled'（明示的にキャンセル）
#    - 処理: ケース5と同様に:canceledを返す
#    - 判定: result.kind == :canceled
#    - 結果: persist_canceled!で契約・メンバーシップをclosedに更新
#
# その他:
# - latest_invoiceが未finalizeで猶予期間超過: :past_due（ケース4と同様）
# - invoiceが現在サイクルに一致しない: :unknown（再試行待ち）
# - その他の未確定状態: :unknown（再試行待ち）
# ==============================================================================

module UserStripe
  class RenewMembershipSubscriptionService < UserStripe::BaseService
    TOLERANCE_SECONDS = 5.minutes.to_i
    CANCELED_LIKE = %w[canceled unpaid incomplete_expired].freeze

    SubscriptionResult = Struct.new(:kind, :stripe_status, :invoice_status, :invoice_id, keyword_init: true)
    # kind: :paid | :past_due | :canceled | :grace | :unknown

    def execute(stripe_record_subscription:)
      validate_tenant!(stripe_record_subscription)

      StripeRecord::Subscription.transaction do
        stripe_record_subscription.with_lock do
          snapshot = fetch_stripe_snapshot!(stripe_record_subscription)
          next unless snapshot

          stripe_subscription, current_period_end, expected_anchor = snapshot

          result, latest_invoice = determine_subscription_result(
            stripe_subscription, stripe_record_subscription, expected_anchor, current_period_end,
          )
          next if result.kind == :unknown

          persist_subscription_result!(result, stripe_subscription, latest_invoice, stripe_record_subscription, current_period_end)
          notify_if_needed!(result, stripe_record_subscription, latest_invoice)
        end
      end
    rescue => e
      Sentry.configure_scope { |s| s.set_extras(subscription_id: stripe_record_subscription.id) }
      Sentry.capture_exception(e)
    end

    private

    # --- Fetch ---
    # ケース1: 自動更新期限前の場合、nilを返してスキップ
    def fetch_stripe_snapshot!(stripe_record_subscription)
      stripe_subscription = Stripe::Subscription.retrieve(
        {
          id: stripe_record_subscription.remote_id,
          expand: [
            'items.data',                         # ← 追加：アイテムを展開
            'latest_invoice.lines.data',
          ],
        },
        AppStripe.request_options,
      )

      # APIの最新仕様に合わせて、アイテム（単一）の current_period_end から求める
      current_period_end = extract_current_period_end_from_single_item!(stripe_subscription)

      expected_anchor = stripe_record_subscription.current_period_end&.to_i
      unless expected_anchor
        raise Exceptions::Payment::UnintentionalResponseError.new(
          response: stripe_subscription,
          message: '`current_period_end` is nil on local record',
        )
      end

      # 期間が進んでいなければ冪等的にスキップ（ケース1: 自動更新期限前）
      return nil unless stripe_record_subscription.current_period_end + 1.hour < current_period_end

      [stripe_subscription, current_period_end, expected_anchor]
    end

    # Subscription は item を1件だけ持つ前提。
    # 展開されていない/件数不一致などの不整合はフェイルファスト。
    def extract_current_period_end_from_single_item!(stripe_subscription)
      items = stripe_subscription.items&.data

      # expand失敗や不整合への保険：必要ならAPIで再取得（limit:2で「複数」の検出も可能）
      if items.blank? || items.size != 1 || items.first.current_period_end.nil?
        fetched = Stripe::SubscriptionItem.list(
          { subscription: stripe_subscription.id, limit: 2 },
          AppStripe.request_options,
        ).data
        items = fetched if fetched.present?
      end

      if items.blank? || items.size != 1 || items.first.current_period_end.nil?
        raise Exceptions::Payment::UnintentionalResponseError.new(
          response: stripe_subscription,
          message: 'subscription must have exactly one item with current_period_end',
        )
      end

      Time.zone.at(items.first.current_period_end)
    end

    # --- Judge ---
    # ケース2-6の判定を行う
    def determine_subscription_result(stripe_subscription, stripe_record_subscription, expected_anchor, _current_period_end)
      latest_invoice_id = stripe_subscription.latest_invoice
      if latest_invoice_id.blank?
        raise Exceptions::Payment::UnintentionalResponseError.new(
          response: stripe_subscription,
          message: '`latest_invoice` is missing',
        )
      end

      # latest_invoiceを別途取得（expandが4レベルを超えるため）
      invoice_id = latest_invoice_id.is_a?(String) ? latest_invoice_id : latest_invoice_id.id
      latest_invoice = fetch_latest_invoice_with_expand(invoice_id)

      # ケース2: 決済未完了（未finalize）の場合
      finalized_at = latest_invoice.status_transitions&.finalized_at
      if finalized_at.blank?
        return determine_unfinalized_result(stripe_subscription, stripe_record_subscription), latest_invoice
      end

      # invoiceが現在サイクルに一致しない場合は再試行待ち
      return SubscriptionResult.new(kind: :unknown), latest_invoice unless invoice_matches_current_cycle?(latest_invoice, expected_anchor)

      # ケース5, 6: キャンセル済み・決済期限切れ
      if CANCELED_LIKE.include?(stripe_subscription.status)
        return SubscriptionResult.new(
          kind: :canceled,
          stripe_status: stripe_subscription.status,
          invoice_status: latest_invoice.status,
          invoice_id: latest_invoice.id,
        ), latest_invoice
      end

      # ケース3: 決済完了
      if latest_invoice.status == 'paid' || payment_intent_succeeded?(latest_invoice)
        return SubscriptionResult.new(
          kind: :paid,
          stripe_status: stripe_subscription.status,
          invoice_status: latest_invoice.status,
          invoice_id: latest_invoice.id,
        ), latest_invoice
      end

      # ケース4: past_due、決済失敗
      if (stripe_subscription.status == 'past_due') || (latest_invoice.status == 'open')
        return SubscriptionResult.new(
          kind: :past_due,
          stripe_status: stripe_subscription.status,
          invoice_status: latest_invoice.status,
          invoice_id: latest_invoice.id,
        ), latest_invoice
      end

      # その他の未確定状態（再試行待ち）
      SubscriptionResult.new(
        kind: :unknown,
        stripe_status: stripe_subscription.status,
        invoice_status: latest_invoice.status,
        invoice_id: latest_invoice.id,
      ).then { |r| [r, latest_invoice] }
    end

    # ケース2: 決済未完了（未finalize）の場合の判定
    # - 猶予期間内: :grace（何もしない）
    # - 猶予期間超過: :past_due
    # - キャンセル済み: :canceled
    def determine_unfinalized_result(stripe_subscription, stripe_record_subscription)
      tenant = stripe_record_subscription.tenant
      grace_over = stripe_record_subscription.current_period_end +
                   tenant.tenant_stripe_account.membership_grace_period_minutes.minutes < Time.zone.now

      if grace_over
        SubscriptionResult.new(kind: :past_due, stripe_status: stripe_subscription.status)
      elsif stripe_subscription.status == 'canceled'
        SubscriptionResult.new(kind: :canceled, stripe_status: stripe_subscription.status)
      else
        SubscriptionResult.new(kind: :grace, stripe_status: stripe_subscription.status)
      end
    end

    def invoice_matches_current_cycle?(invoice, expected_anchor)
      return false unless invoice.respond_to?(:lines) && invoice.lines.respond_to?(:data)

      lines_data = invoice.lines.data
      return false if lines_data.blank?

      starts = lines_data.map { |l| l.period&.start }.compact.map(&:to_i).reject(&:zero?)
      return false if starts.blank?

      max_start = starts.max
      return false unless max_start

      (max_start - expected_anchor).abs <= TOLERANCE_SECONDS
    end

    def payment_intent_succeeded?(invoice)
      payment_intent = extract_payment_intent_from_invoice(invoice)
      return false if payment_intent.nil?

      return payment_intent.status == 'succeeded' if payment_intent.is_a?(Stripe::PaymentIntent)

      Stripe::PaymentIntent.retrieve({ id: payment_intent.id }, AppStripe.request_options).status == 'succeeded'
    end

    # --- Persist（Tx内・冪等更新） ---
    # 各ケースに応じた処理を実行
    def persist_subscription_result!(result, stripe_subscription, latest_invoice, stripe_record_subscription, current_period_end)
      case result.kind
      when :paid
        # ケース3: 決済完了 → 契約・サブスクリプション・メンバーシップを更新
        persist_paid!(stripe_subscription, latest_invoice, stripe_record_subscription, current_period_end)
      when :canceled
        # ケース5, 6: キャンセル済み・決済期限切れ → 契約・メンバーシップをclosedに更新
        persist_canceled!(stripe_subscription, stripe_record_subscription)
      when :past_due
        # ケース4: past_due、決済失敗 → 何もしない（active維持）
        persist_past_due!(stripe_record_subscription)
      when :grace, :unknown
        # ケース2（猶予期間内）または未確定のため何もしない
        nil
      end
    end

    def persist_paid!(stripe_subscription, latest_invoice, stripe_record_subscription, current_period_end)
      contract      = stripe_record_subscription.payment_subscription.membership_contract
      current_term  = contract.current_contract_term

      contract.with_lock do
        current_term.lock!
        contract.membership_users.each(&:lock!)

        contract.status     = :active if contract.status == 'past_due'
        contract.expired_at = current_period_end
        contract.save!

        stripe_record_subscription.update!(
          current_period_end: current_period_end,
          status: stripe_subscription.status,
        )

        upsert_payment_records!(contract:, stripe_record_subscription:, invoice: latest_invoice, current_period_end:)

        current_term.update!(end_at: current_period_end)
        contract.membership_users.each { |mu| mu.update!(status: 'active', expired_at: current_period_end) }
      end
    end

    def persist_canceled!(stripe_subscription, stripe_record_subscription)
      contract = stripe_record_subscription.payment_subscription.membership_contract
      contract.with_lock do
        contract.update!(status: 'canceled')
        contract.membership_users.each { |mu| mu.update!(status: 'closed') }
        term = contract.current_contract_term
        term.lock!
        term.update!(status: 'closed', end_at: Time.zone.now)
      end
      stripe_record_subscription.update!(status: stripe_subscription.status)
    end

    def persist_past_due!(_stripe_record_subscription)
      # 必要ならpast_dueを記録（active維持）
    end

    # --- UPSERT ---
    def upsert_payment_records!(contract:, stripe_record_subscription:, invoice:, current_period_end:)
      payment_intent = ensure_payment_intent(invoice)
      return unless payment_intent

      sri = StripeRecord::Invoice.create_or_find_by!(remote_id: invoice.id) do |r|
        r.user           = contract.user
        r.tenant_id      = contract.tenant_id
        r.payment_source = stripe_record_subscription
      end
      sri.update!(
        status: invoice.status,
        confirmation_secret: invoice&.confirmation_secret&.client_secret,
        confirmation_secret_type: invoice&.confirmation_secret&.client_secret.present? ? 'payment_intent' : nil,
      )

      tenant = stripe_record_subscription.tenant
      srpi = StripeRecord::PaymentIntent.find_or_initialize_by(remote_id: payment_intent.id)
      srpi.user            = contract.user
      srpi.tenant_id       = contract.tenant_id
      srpi.api_key_account = tenant.tenant_stripe_account.stripe_account
      srpi.chargeable      = stripe_record_subscription
      srpi.invoice         = sri
      srpi.assign_remote_attributes(payment_intent)
      # assign_remote_attributes で埋まらない分を補完
      srpi.client_secret = payment_intent&.client_secret
      srpi.confirmation_method = payment_intent.confirmation_method if payment_intent.respond_to?(:confirmation_method)
      srpi.capture_method = payment_intent.capture_method if payment_intent.respond_to?(:capture_method)
      srpi.save!

      txn = Payment::Transaction.find_or_initialize_by(
        tenant_id: contract.tenant_id,
        payment_provider: 'stripe',
        chargeable: srpi,
      )
      txn.user                = contract.user
      txn.membership_contract = contract
      txn.payment_type        = 'credit_card'
      txn.paid_amount         = invoice.amount_paid
      txn.activated_at        = Time.zone.now
      txn.expired_at          = current_period_end
      txn.status              = 'active'
      txn.recurrence          = true
      txn.save!
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def ensure_payment_intent(invoice)
      payment_intent = extract_payment_intent_from_invoice(invoice)
      return nil if payment_intent.nil?
      return payment_intent if payment_intent.is_a?(Stripe::PaymentIntent)

      Stripe::PaymentIntent.retrieve({ id: payment_intent.id }, AppStripe.request_options)
    end

    def fetch_latest_invoice_with_expand(invoice_id)
      Stripe::Invoice.retrieve(
        {
          id: invoice_id,
          expand: [
            'payments.data.payment.payment_intent',
            'lines.data',
          ],
        },
        AppStripe.request_options,
      )
    end

    def extract_payment_intent_from_invoice(invoice)
      # invoice.payments.dataから最新のpayment_intentを取得
      return nil unless invoice.respond_to?(:payments) && invoice.payments.respond_to?(:data)

      payments = invoice.payments.data
      return nil if payments.blank?

      # 最初のpaymentからpayment_intentを取得（通常は最新のもの）
      first_payment = payments.first
      return nil unless first_payment.respond_to?(:payment) && first_payment.payment.respond_to?(:payment_intent)

      first_payment.payment.payment_intent
    end

    # --- Notify ---
    def notify_if_needed!(result, stripe_record_subscription, _invoice)
      return unless result.kind == :paid

      contract = stripe_record_subscription.payment_subscription.membership_contract
      return unless should_send_renewal_email?(contract)

      UserStripe::SendRenewSubscriptionEmailService.new.execute!(user: contract.user, membership_contract: contract)
    end

    def should_send_renewal_email?(contract)
      ct = contract.current_contract_term
      mp = ct.membership_plan
      tenant = contract.tenant
      yearly_no_upcoming = contract.upcoming_contract_term.nil? && mp&.recurring_interval_unit == 'year'
      yearly_no_upcoming || tenant.tenant_stripe_account.send_subscription_update_succeeded_email_for_all_intervals
    end

    # --- Guard ---
    def validate_tenant!(stripe_record_subscription)
      tenant = stripe_record_subscription.tenant
      raise Exceptions::Payment::TenantNotSetError if tenant.nil?
      raise Exceptions::Payment::TenantNotMatchError if tenant.id != stripe_record_subscription.tenant_id
    end
  end
end
