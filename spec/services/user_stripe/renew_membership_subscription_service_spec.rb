# typed: false

RSpec.describe UserStripe::RenewMembershipSubscriptionService do
  subject(:execute) {
    described_class.new.execute(stripe_record_subscription: stripe_record_subscription)
  }

  let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com') }
  let(:current_user) { create(:user, tenant_id: current_tenant.id) }
  let(:tenant_stripe_account) {
    create(:tenant_stripe_account, :with_account, tenant_id: current_tenant.id, membership_grace_period_minutes: 30)
  }
  let(:membership_group) { create(:membership_group, tenant_id: current_tenant.id) }
  let(:membership) { create(:membership, tenant_id: current_tenant.id, membership_group:) }
  let(:membership_plan) {
    create(:membership_plan, tenant_id: current_tenant.id, recurring_interval_unit: 'month', recurring_interval_count: 1)
  }
  let(:expired_at_base) { Time.zone.parse('2025-10-15 00:00:00') }
  let(:membership_contract) {
    create(:membership_contract, tenant_id: current_tenant.id, user: current_user, status: 'active', expired_at: expired_at_base)
  }
  let(:contract_term) {
    create(:membership_contract_term, membership_contract:, membership_plan:, payment_type: 'credit_card', status: 'current')
  }
  let(:membership_user) {
    create(:membership_user, tenant_id: current_tenant.id, user: current_user, membership:, membership_contract:, status: 'active')
  }
  let(:stripe_record_product) { create(:stripe_record_product, tenant_id: current_tenant.id) }
  let(:stripe_record_price) { create(:stripe_record_price, tenant_id: current_tenant.id, product: stripe_record_product) }
  let(:stripe_record_subscription) {
    create(:stripe_record_subscription,
      tenant_id: current_tenant.id,
      user: current_user,
      product: stripe_record_product,
      price: stripe_record_price,
      status: 'active',
      current_period_end: expired_at_base,
      remote_id: 'sub_test123',)
  }
  let(:payment_subscription) {
    create(:payment_subscription, tenant_id: current_tenant.id, user: current_user, membership_contract:, subscribable: stripe_record_subscription)
  }

  before do
    tenant_stripe_account
    membership_contract
    contract_term
    membership_user
    payment_subscription
  end

  describe '#execute' do
    context 'ケース1: 自動更新期限前' do
      before do
        # current_period_endがまだ未来（1時間以内）の場合
        stripe_record_subscription.update!(current_period_end: 1.hour.from_now)

        # Stripe APIのモック
        # rubocop:disable RSpec/VerifiedDoubles
        mock_subscription_item = double('Stripe::SubscriptionItem', current_period_end: 1.hour.from_now.to_i)
        mock_items = double('Stripe::ListObject', data: [mock_subscription_item])
        mock_stripe_subscription = double('Stripe::Subscription',
          id: 'sub_test123',
          status: 'active',
          items: mock_items,
          latest_invoice: 'in_test123',)
        # rubocop:enable RSpec/VerifiedDoubles
        allow(Stripe::Subscription).to receive(:retrieve).and_return(mock_stripe_subscription)
        # Stripe::SubscriptionItem.listのモック（保険として）
        # rubocop:disable RSpec/VerifiedDoubles
        allow(Stripe::SubscriptionItem).to receive(:list).and_return(double('Stripe::ListObject', data: [mock_subscription_item]))
        # rubocop:enable RSpec/VerifiedDoubles
      end

      it '何もしない（nilを返してスキップ）' do
        result = execute
        expect(result).to be_nil
        expect(membership_contract.reload.status).to eq 'active'
        expect(membership_contract.reload.expired_at).to be_within(1.second).of(expired_at_base)
      end
    end

    context 'ケース2: 自動更新期限後(決済未完了) - 猶予期間内' do
      let(:new_period_end) { 1.month.from_now }

      before do
        stripe_record_subscription.update!(current_period_end: expired_at_base)

        # Stripe APIのモック
        # rubocop:disable RSpec/VerifiedDoubles
        mock_subscription_item = double('Stripe::SubscriptionItem', current_period_end: new_period_end.to_i)
        mock_items = double('Stripe::ListObject', data: [mock_subscription_item])
        mock_stripe_subscription = double('Stripe::Subscription',
          id: 'sub_test123',
          status: 'active',
          items: mock_items,
          latest_invoice: 'in_test123',)
        # rubocop:enable RSpec/VerifiedDoubles
        allow(Stripe::Subscription).to receive(:retrieve).and_return(mock_stripe_subscription)
        # rubocop:disable RSpec/VerifiedDoubles
        allow(Stripe::SubscriptionItem).to receive(:list).and_return(double('Stripe::ListObject', data: [mock_subscription_item]))

        # Invoiceが未finalize（status_transitions.finalized_atがnil）
        mock_invoice_lines = double('Stripe::ListObject', data: [
          double('Stripe::InvoiceLineItem', period: double('period', start: expired_at_base.to_i)),
        ],)
        # rubocop:enable RSpec/VerifiedDoubles
        mock_invoice = instance_double(Stripe::Invoice,
          id: 'in_test123',
          status: 'open',
          status_transitions: nil,
          lines: mock_invoice_lines,)
        allow(Stripe::Invoice).to receive(:retrieve).and_return(mock_invoice)
      end

      it '何もしない（:graceを返す）' do
        result = execute
        expect(result).to be_nil
        expect(membership_contract.reload.status).to eq 'active'
        expect(membership_contract.reload.expired_at).to be_within(1.second).of(expired_at_base)
      end
    end

    context 'ケース3: 自動更新期限後(決済完了)' do
      let(:new_period_end) { expired_at_base + 1.month }
      let(:expected_anchor) { expired_at_base.to_i }

      before do
        stripe_record_subscription.update!(current_period_end: expired_at_base)

        # Stripe APIのモック
        # rubocop:disable RSpec/VerifiedDoubles
        mock_subscription_item = double('Stripe::SubscriptionItem', current_period_end: new_period_end.to_i)
        mock_items = double('Stripe::ListObject', data: [mock_subscription_item])
        mock_stripe_subscription = double('Stripe::Subscription',
          id: 'sub_test123',
          status: 'active',
          items: mock_items,
          latest_invoice: 'in_test123',)
        # rubocop:enable RSpec/VerifiedDoubles
        allow(Stripe::Subscription).to receive(:retrieve).and_return(mock_stripe_subscription)
        # rubocop:disable RSpec/VerifiedDoubles
        allow(Stripe::SubscriptionItem).to receive(:list).and_return(double('Stripe::ListObject', data: [mock_subscription_item]))
        # rubocop:enable RSpec/VerifiedDoubles

        # Invoiceがpaid
        mock_payment_intent = Stripe::PaymentIntent.construct_from({
          id: 'pi_test123',
          status: 'succeeded',
          amount: 1000,
          currency: 'jpy',
          customer: 'cus_test123',
          payment_method: 'pm_test123',
          created: Time.current.to_i,
          canceled_at: nil,
          confirmation_method: 'automatic',
          capture_method: 'automatic',
          client_secret: 'pi_test123_secret',
        })
        # rubocop:disable RSpec/VerifiedDoubles
        payments_item_payment = double('payment', payment_intent: mock_payment_intent)
        payments_item = double('invoice_payment', payment: payments_item_payment)
        payments_list = double('payments', data: [payments_item])
        # rubocop:enable RSpec/VerifiedDoubles
        # rubocop:disable RSpec/VerifiedDoubles
        mock_period = double('period', start: expected_anchor)
        mock_invoice_line_item = double('Stripe::InvoiceLineItem', period: mock_period)
        mock_invoice_lines = double('Stripe::ListObject', data: [mock_invoice_line_item])
        # rubocop:enable RSpec/VerifiedDoubles
        mock_invoice = instance_double(Stripe::Invoice,
          id: 'in_test123',
          status: 'paid',
          amount_paid: 1000,
          # rubocop:disable RSpec/VerifiedDoubles
          status_transitions: double('status_transitions', finalized_at: 1.hour.ago.to_i),
          # rubocop:enable RSpec/VerifiedDoubles
          lines: mock_invoice_lines,
          payments: payments_list,
          confirmation_secret: nil,)
        allow(Stripe::Invoice).to receive(:retrieve).and_return(mock_invoice)
        allow(Stripe::PaymentIntent).to receive(:retrieve).and_return(mock_payment_intent)
      end

      it '契約・サブスクリプション・メンバーシップを更新する' do
        result = execute
        expect(result).to be_nil # executeは戻り値なし

        membership_contract.reload
        expect(membership_contract.status).to eq 'active'
        expect(membership_contract.reload.expired_at.to_i).to eq new_period_end.to_i

        stripe_record_subscription.reload
        expect(stripe_record_subscription.current_period_end.to_i).to eq new_period_end.to_i
        expect(stripe_record_subscription.status).to eq 'active'

        membership_user.reload
        expect(membership_user.status).to eq 'active'
        expect(membership_user.expired_at.to_i).to eq new_period_end.to_i

        contract_term.reload
        expect(contract_term.end_at.to_i).to eq new_period_end.to_i

        # PaymentTransactionが作成されている
        payment_transaction = Payment::Transaction.find_by(membership_contract:, payment_provider: 'stripe')
        expect(payment_transaction).to be_present
        expect(payment_transaction.status).to eq 'active'
        expect(payment_transaction.recurrence).to be true
      end
    end

    context 'ケース4: 自動更新期限後(past_due、決済失敗)' do
      let(:new_period_end) { expired_at_base + 1.month }
      let(:expected_anchor) { expired_at_base.to_i }

      before do
        stripe_record_subscription.update!(current_period_end: expired_at_base)

        # Stripe APIのモック
        # rubocop:disable RSpec/VerifiedDoubles
        mock_subscription_item = double('Stripe::SubscriptionItem', current_period_end: new_period_end.to_i)
        mock_items = double('Stripe::ListObject', data: [mock_subscription_item])
        mock_stripe_subscription = double('Stripe::Subscription',
          id: 'sub_test123',
          status: 'past_due',
          items: mock_items,
          latest_invoice: 'in_test123',)
        # rubocop:enable RSpec/VerifiedDoubles
        allow(Stripe::Subscription).to receive(:retrieve).and_return(mock_stripe_subscription)
        # rubocop:disable RSpec/VerifiedDoubles
        allow(Stripe::SubscriptionItem).to receive(:list).and_return(double('Stripe::ListObject', data: [mock_subscription_item]))
        # rubocop:enable RSpec/VerifiedDoubles

        # Invoiceがopen（決済失敗）
        # rubocop:disable RSpec/VerifiedDoubles
        mock_invoice_lines = double('Stripe::ListObject', data: [
          double('Stripe::InvoiceLineItem', period: double('period', start: expected_anchor)),
        ],)
        # rubocop:enable RSpec/VerifiedDoubles
        mock_invoice = instance_double(Stripe::Invoice,
          id: 'in_test123',
          status: 'open',
          # rubocop:disable RSpec/VerifiedDoubles
          status_transitions: double('status_transitions', finalized_at: 1.hour.ago.to_i),
          # rubocop:enable RSpec/VerifiedDoubles
          lines: mock_invoice_lines,)
        allow(Stripe::Invoice).to receive(:retrieve).and_return(mock_invoice)
      end

      it '何もしない（active維持）' do
        result = execute
        expect(result).to be_nil

        membership_contract.reload
        expect(membership_contract.status).to eq 'active'
        expect(membership_contract.expired_at).to be_within(1.second).of(expired_at_base)
      end
    end

    context 'ケース5: 自動更新期限後(決済期限切れ、canceled)' do
      let(:new_period_end) { expired_at_base + 1.month }
      let(:expected_anchor) { expired_at_base.to_i }

      before do
        stripe_record_subscription.update!(current_period_end: expired_at_base)

        # Stripe APIのモック
        # rubocop:disable RSpec/VerifiedDoubles
        mock_subscription_item = double('Stripe::SubscriptionItem', current_period_end: new_period_end.to_i)
        mock_items = double('Stripe::ListObject', data: [mock_subscription_item])
        mock_stripe_subscription = double('Stripe::Subscription',
          id: 'sub_test123',
          status: 'unpaid',
          items: mock_items,
          latest_invoice: 'in_test123',)
        # rubocop:enable RSpec/VerifiedDoubles
        allow(Stripe::Subscription).to receive(:retrieve).and_return(mock_stripe_subscription)
        # rubocop:disable RSpec/VerifiedDoubles
        allow(Stripe::SubscriptionItem).to receive(:list).and_return(double('Stripe::ListObject', data: [mock_subscription_item]))
        # rubocop:enable RSpec/VerifiedDoubles

        # Invoiceがopen
        # rubocop:disable RSpec/VerifiedDoubles
        mock_invoice_lines = double('Stripe::ListObject', data: [
          double('Stripe::InvoiceLineItem', period: double('period', start: expected_anchor)),
        ],)
        # rubocop:enable RSpec/VerifiedDoubles
        mock_invoice = instance_double(Stripe::Invoice,
          id: 'in_test123',
          status: 'open',
          # rubocop:disable RSpec/VerifiedDoubles
          status_transitions: double('status_transitions', finalized_at: 1.hour.ago.to_i),
          # rubocop:enable RSpec/VerifiedDoubles
          lines: mock_invoice_lines,)
        allow(Stripe::Invoice).to receive(:retrieve).and_return(mock_invoice)
      end

      it '契約・メンバーシップをclosedに更新する' do
        result = execute
        expect(result).to be_nil

        membership_contract.reload
        expect(membership_contract.status).to eq 'canceled'

        membership_user.reload
        expect(membership_user.status).to eq 'closed'

        contract_term.reload
        expect(contract_term.status).to eq 'closed'

        stripe_record_subscription.reload
        expect(stripe_record_subscription.status).to eq 'unpaid'
      end
    end

    context 'ケース6: 自動更新キャンセル済み' do
      let(:new_period_end) { expired_at_base + 1.month }
      let(:expected_anchor) { expired_at_base.to_i }

      before do
        stripe_record_subscription.update!(current_period_end: expired_at_base, status: 'active')

        # Stripe APIのモック
        # rubocop:disable RSpec/VerifiedDoubles
        mock_subscription_item = double('Stripe::SubscriptionItem', current_period_end: new_period_end.to_i)
        mock_items = double('Stripe::ListObject', data: [mock_subscription_item])
        mock_stripe_subscription = double('Stripe::Subscription',
          id: 'sub_test123',
          status: 'canceled',
          items: mock_items,
          latest_invoice: 'in_test123',)
        # rubocop:enable RSpec/VerifiedDoubles
        allow(Stripe::Subscription).to receive(:retrieve).and_return(mock_stripe_subscription)
        # rubocop:disable RSpec/VerifiedDoubles
        allow(Stripe::SubscriptionItem).to receive(:list).and_return(double('Stripe::ListObject', data: [mock_subscription_item]))
        # rubocop:enable RSpec/VerifiedDoubles

        # Invoiceがopen
        # rubocop:disable RSpec/VerifiedDoubles
        mock_invoice_lines = double('Stripe::ListObject', data: [
          double('Stripe::InvoiceLineItem', period: double('period', start: expected_anchor)),
        ],)
        # rubocop:enable RSpec/VerifiedDoubles
        mock_invoice = instance_double(Stripe::Invoice,
          id: 'in_test123',
          status: 'open',
          # rubocop:disable RSpec/VerifiedDoubles
          status_transitions: double('status_transitions', finalized_at: 1.hour.ago.to_i),
          # rubocop:enable RSpec/VerifiedDoubles
          lines: mock_invoice_lines,)
        allow(Stripe::Invoice).to receive(:retrieve).and_return(mock_invoice)
      end

      it '契約・メンバーシップをclosedに更新する' do
        result = execute
        expect(result).to be_nil

        membership_contract.reload
        expect(membership_contract.status).to eq 'canceled'

        membership_user.reload
        expect(membership_user.status).to eq 'closed'

        contract_term.reload
        expect(contract_term.status).to eq 'closed'

        stripe_record_subscription.reload
        expect(stripe_record_subscription.status).to eq 'canceled'
      end
    end

    context 'その他: invoiceが現在サイクルに一致しない場合' do
      let(:new_period_end) { expired_at_base + 1.month }
      let(:unexpected_anchor) { (expired_at_base - 1.month).to_i }

      before do
        stripe_record_subscription.update!(current_period_end: expired_at_base)

        # Stripe APIのモック
        # rubocop:disable RSpec/VerifiedDoubles
        mock_subscription_item = double('Stripe::SubscriptionItem', current_period_end: new_period_end.to_i)
        mock_items = double('Stripe::ListObject', data: [mock_subscription_item])
        mock_stripe_subscription = double('Stripe::Subscription',
          id: 'sub_test123',
          status: 'active',
          items: mock_items,
          latest_invoice: 'in_test123',)
        # rubocop:enable RSpec/VerifiedDoubles
        allow(Stripe::Subscription).to receive(:retrieve).and_return(mock_stripe_subscription)
        # rubocop:disable RSpec/VerifiedDoubles
        allow(Stripe::SubscriptionItem).to receive(:list).and_return(double('Stripe::ListObject', data: [mock_subscription_item]))
        # rubocop:enable RSpec/VerifiedDoubles

        # Invoiceが異なるサイクルのもの
        # rubocop:disable RSpec/VerifiedDoubles
        mock_invoice_lines = double('Stripe::ListObject', data: [
          double('Stripe::InvoiceLineItem', period: double('period', start: unexpected_anchor)),
        ],)
        # rubocop:enable RSpec/VerifiedDoubles
        mock_invoice = instance_double(Stripe::Invoice,
          id: 'in_test123',
          status: 'paid',
          # rubocop:disable RSpec/VerifiedDoubles
          status_transitions: double('status_transitions', finalized_at: 1.hour.ago.to_i),
          # rubocop:enable RSpec/VerifiedDoubles
          lines: mock_invoice_lines,)
        allow(Stripe::Invoice).to receive(:retrieve).and_return(mock_invoice)
      end

      it '何もしない（:unknownを返して再試行待ち）' do
        result = execute
        expect(result).to be_nil

        membership_contract.reload
        expect(membership_contract.status).to eq 'active'
        expect(membership_contract.expired_at).to be_within(1.second).of(expired_at_base)
      end
    end

    context 'その他: 猶予期間超過で未finalizeの場合' do
      let(:new_period_end) { expired_at_base + 1.month }

      before do
        # 猶予期間を超過（31分前）
        stripe_record_subscription.update!(current_period_end: 31.minutes.ago)

        # Stripe APIのモック
        # rubocop:disable RSpec/VerifiedDoubles
        mock_subscription_item = double('Stripe::SubscriptionItem', current_period_end: new_period_end.to_i)
        mock_items = double('Stripe::ListObject', data: [mock_subscription_item])
        mock_stripe_subscription = double('Stripe::Subscription',
          id: 'sub_test123',
          status: 'active',
          items: mock_items,
          latest_invoice: 'in_test123',)
        # rubocop:enable RSpec/VerifiedDoubles
        allow(Stripe::Subscription).to receive(:retrieve).and_return(mock_stripe_subscription)
        # rubocop:disable RSpec/VerifiedDoubles
        allow(Stripe::SubscriptionItem).to receive(:list).and_return(double('Stripe::ListObject', data: [mock_subscription_item]))
        # rubocop:enable RSpec/VerifiedDoubles

        # Invoiceが未finalize
        # rubocop:disable RSpec/VerifiedDoubles
        mock_invoice_lines = double('Stripe::ListObject', data: [
          double('Stripe::InvoiceLineItem', period: double('period', start: 31.minutes.ago.to_i)),
        ],)
        # rubocop:enable RSpec/VerifiedDoubles
        mock_invoice = instance_double(Stripe::Invoice,
          id: 'in_test123',
          status: 'open',
          status_transitions: nil,
          lines: mock_invoice_lines,)
        allow(Stripe::Invoice).to receive(:retrieve).and_return(mock_invoice)
      end

      it '何もしない（:past_dueを返す）' do
        result = execute
        expect(result).to be_nil

        membership_contract.reload
        expect(membership_contract.status).to eq 'active'
      end
    end

    context 'エラーハンドリング' do
      before do
        stripe_record_subscription.update!(current_period_end: expired_at_base)

        # Stripe APIでエラーが発生
        allow(Stripe::Subscription).to receive(:retrieve).and_raise(Stripe::StripeError.new('API Error'))
        allow(Sentry).to receive(:configure_scope)
        allow(Sentry).to receive(:capture_exception)
      end

      it 'エラーをキャッチしてSentryに送信する' do
        result = execute
        expect(result).to be_nil

        expect(Sentry).to have_received(:configure_scope)
        expect(Sentry).to have_received(:capture_exception)
      end
    end
  end
end
