# typed: false

require 'stripe'

# --- Shared Contexts & Examples ---
RSpec.shared_context 'membership and stripe setup' do
  let(:current_user) {
    create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'Password1234!')
  }
  let(:leveled_membership_group) { create(:membership_group, :with_leveled_memberships, tenant_id: current_tenant.id, name: 'leveled_membership_group') }
  let(:leveled_membership_platinum) { leveled_membership_group.memberships.find_by(name: 'platinum') }
  let(:leveled_membership_premium) { leveled_membership_group.memberships.find_by(name: 'premium') }
  let(:leveled_membership_basic) { leveled_membership_group.memberships.find_by(name: 'basic') }
  let(:stripe_record_product_platinum) { create(:stripe_record_product, tenant_id: current_tenant.id, name: 'platinum_product') }
  let(:stripe_record_product_premium) { create(:stripe_record_product, tenant_id: current_tenant.id, name: 'premium_product') }
  let(:stripe_record_product_basic) { create(:stripe_record_product, tenant_id: current_tenant.id, name: 'basic_product') }
  let(:leveled_membership_plan_platinum) {
    create(:membership_plan, tenant_id: current_tenant.id, name: 'platinum_plan', recurring_interval_count: 1, recurring_interval_unit: 'month', position: 1, amount: 5000)
  }
  let(:leveled_membership_plan_premium) {
    create(:membership_plan, tenant_id: current_tenant.id, name: 'premium_plan', recurring_interval_count: 1, recurring_interval_unit: 'month', position: 2, amount: 3000)
  }
  let(:leveled_membership_plan_basic) {
    create(:membership_plan, tenant_id: current_tenant.id, name: 'basic_plan', recurring_interval_count: 1, recurring_interval_unit: 'month', position: 3, amount: 1000)
  }
  let(:stripe_record_price_platinum) {
    create(:stripe_record_price, tenant_id: current_tenant.id, product: stripe_record_product_platinum, amount: leveled_membership_plan_platinum.amount)
  }
  let(:stripe_record_price_premium) { create(:stripe_record_price, tenant_id: current_tenant.id, product: stripe_record_product_premium, amount: leveled_membership_plan_premium.amount) }
  let(:stripe_record_price_basic) { create(:stripe_record_price, tenant_id: current_tenant.id, product: stripe_record_product_basic, amount: leveled_membership_plan_basic.amount) }
  let(:membership_plan_payment_method_platinum) {
    create(:membership_plan_payment_method, tenant_id: current_tenant.id, membership_plan: leveled_membership_plan_platinum, payment_type: 'credit_card',
stripe_record_price: stripe_record_price_platinum, is_active: true,)
  }
  let(:membership_plan_payment_method_premium) {
    create(:membership_plan_payment_method, tenant_id: current_tenant.id, membership_plan: leveled_membership_plan_premium, payment_type: 'credit_card',
stripe_record_price: stripe_record_price_premium, is_active: true,)
  }
  let(:membership_plan_payment_method_basic) {
    create(:membership_plan_payment_method, tenant_id: current_tenant.id, membership_plan: leveled_membership_plan_basic, payment_type: 'credit_card',
stripe_record_price: stripe_record_price_basic, is_active: true,)
  }
  let(:membership_plan_component_platinum) {
    create(:membership_plan_component, tenant_id: current_tenant.id, membership_plan: leveled_membership_plan_platinum, membership: leveled_membership_platinum)
  }
  let(:membership_plan_component_premium) {
    create(:membership_plan_component, tenant_id: current_tenant.id, membership_plan: leveled_membership_plan_premium, membership: leveled_membership_premium)
  }
  let(:membership_plan_component_basic) {
    create(:membership_plan_component, tenant_id: current_tenant.id, membership_plan: leveled_membership_plan_basic, membership: leveled_membership_basic)
  }
  let(:contract) { create(:membership_contract, tenant_id: current_tenant.id, user: current_user, membership_plan: leveled_membership_plan_platinum) }
  let(:stripe_subscription) { create(:stripe_record_subscription, tenant_id: current_tenant.id, user: current_user, price: stripe_record_price_platinum) }
  let(:current_user_stripe_payment_method) {
    create(:stripe_record_payment_method, tenant_id: current_tenant.id, user: current_user, type: 'card', api_key_account: tenant_stripe_account.stripe_account, remote_id: 'pm_test123')
  }
  let(:tenant_stripe_account) { create(:tenant_stripe_account, :with_account, tenant_id: current_tenant.id) }

  before do
    # Mock Stripe::Account.retrieve for APIKey validation
    # rubocop:disable RSpec/VerifiedDoubles
    mock_stripe_account = double('Stripe::Account')
    allow(mock_stripe_account).to receive_messages(id: 'acct_test123', settings: double('settings', dashboard: double('dashboard', display_name: 'Test Account')))
    # rubocop:enable RSpec/VerifiedDoubles
    allow(Stripe::Account).to receive(:retrieve).and_return(mock_stripe_account)
    membership_plan_component_platinum
    membership_plan_component_premium
    membership_plan_component_basic
    current_user_stripe_payment_method
    membership_plan_payment_method_platinum
    membership_plan_payment_method_premium
    membership_plan_payment_method_basic
    tenant_stripe_account # ensure let is referenced
  end
end

RSpec.shared_context 'stripe api mocks' do
  # rubocop:disable  Metrics/AbcSize

  # rubocop:disable RSpec/VerifiedDoubles
  let(:confirmation_secret) { double('confirmation_secret', client_secret: 'pi_test123_secret') }
  # rubocop:enable RSpec/VerifiedDoubles
  let(:latest_invoice_double) { instance_double(Stripe::Invoice, id: 'in_test123', confirmation_secret:) }
  let(:pending_setup_intent_double) { nil }
  def mock_stripe_apis
    mock_stripe_card = Stripe::Card.new
    allow(mock_stripe_card).to receive(:fingerprint).and_return('test_card_fingerprint')
    mock_stripe_payment_method = Stripe::PaymentMethod.new
    allow(mock_stripe_payment_method).to receive(:card).and_return(mock_stripe_card)
    mock_stripe_customer = Stripe::Customer.new
    # rubocop:disable RSpec/VerifiedDoubles
    allow(mock_stripe_customer).to receive_messages(invoice_settings: double('invoice_settings', default_payment_method: mock_stripe_payment_method), default_source: nil)
    # rubocop:enable RSpec/VerifiedDoubles
    allow(Stripe::Customer).to receive(:retrieve).and_return(mock_stripe_customer)
    # rubocop:disable RSpec/VerifiedDoubles
    mock_stripe_subscription = double('Stripe::Subscription')
    allow(mock_stripe_subscription).to receive_messages(
      id: 'sub_test123',
      status: 'incomplete',
      trial_end: nil,
      trial_start: nil,
      current_period_start: Time.current.to_i,
      current_period_end: 1.month.from_now.to_i,
      items: double('items', data: [
        double('subscription_item', current_period_start: Time.current.to_i, current_period_end: 1.month.from_now.to_i),
      ],),
      latest_invoice: latest_invoice_double,
      pending_setup_intent: pending_setup_intent_double,
    )
    # rubocop:enable RSpec/VerifiedDoubles
    allow(Stripe::Subscription).to receive_messages(create: mock_stripe_subscription, retrieve: mock_stripe_subscription, update: mock_stripe_subscription)
    # Invoice.retrieve で返すオブジェクトに payments.data.first.payment.payment_intent を持たせる
    mock_stripe_invoice = instance_double(Stripe::Invoice)
    # PaymentIntent の必要最小限フィールドを実体で用意（Sorbet型チェック対応）
    mock_payment_intent = Stripe::PaymentIntent.construct_from(
      {
        id: 'pi_test123',
        amount: 500,
        currency: 'jpy',
        status: 'requires_confirmation',
        customer: 'cus_test123',
        payment_method: 'pm_test123',
        payment_method_configuration_details: nil,
        payment_method_options: { card: { request_three_d_secure: 'automatic' } },
        cancellation_reason: nil,
        description: 'Subscription creation',
        metadata: {},
        next_action: nil,
        on_behalf_of: nil,
        application_fee_amount: nil,
        transfer_data: nil,
        transfer_group: nil,
        created: Time.current.to_i,
        canceled_at: nil,
        confirmation_method: 'automatic',
        capture_method: 'automatic',
        client_secret: 'pi_test123_secret',
      },
    )

    # payments のネスト構造
    # rubocop:disable RSpec/VerifiedDoubles
    payments_item_payment = double('payment', payment_intent: mock_payment_intent)
    payments_item = double('invoice_payment', payment: payments_item_payment)
    payments_list = double('payments', data: [payments_item])
    allow(mock_stripe_invoice).to receive_messages(
      id: 'in_test123',
      status: 'open',
      confirmation_secret: double('confirmation_secret', client_secret: 'pi_test123_secret'),
      payments: payments_list,
    )
    # rubocop:enable RSpec/VerifiedDoubles
    allow(Stripe::Invoice).to receive(:retrieve).and_return(mock_stripe_invoice)
    mock_stripe_setup_intent = instance_double(Stripe::SetupIntent)
    allow(mock_stripe_setup_intent).to receive_messages(id: 'seti_test123', status: 'requires_payment_method', usage: 'off_session', client_secret: 'seti_test123_secret')
    allow(Stripe::SetupIntent).to receive(:retrieve).and_return(mock_stripe_setup_intent)
    mock_stripe_payment_method = instance_double(Stripe::PaymentMethod)
    # rubocop:disable RSpec/VerifiedDoubles
    allow(mock_stripe_payment_method).to receive(:card).and_return(double('card', fingerprint: 'test_fingerprint'))
    # rubocop:enable RSpec/VerifiedDoubles
    allow(Stripe::PaymentMethod).to receive(:retrieve).and_return(mock_stripe_payment_method)
    mock_stripe_card = instance_double(Stripe::Card)
    allow(mock_stripe_card).to receive(:fingerprint).and_return('test_fingerprint')
    allow(Stripe::Card).to receive(:retrieve).and_return(mock_stripe_card)
    # rubocop:disable RSpec/VerifiedDoubles
    mock_stripe_account = double('Stripe::Account')
    allow(mock_stripe_account).to receive_messages(id: 'acct_test123', type: 'standard', display_name: 'Test Account')
    # rubocop:enable RSpec/VerifiedDoubles
    allow(Stripe::Account).to receive(:retrieve).and_return(mock_stripe_account)
    mock_stripe_subscription_schedule = instance_double(Stripe::SubscriptionSchedule)
    # rubocop:disable RSpec/VerifiedDoubles
    allow(mock_stripe_subscription_schedule).to receive_messages(id: 'sub_sched_test123', status: 'active',
current_phase: double('current_phase', start_date: Time.current.to_i, end_date: 1.month.from_now.to_i),)
    # rubocop:enable RSpec/VerifiedDoubles
    allow(Stripe::SubscriptionSchedule).to receive_messages(retrieve: mock_stripe_subscription_schedule, create: mock_stripe_subscription_schedule, update: mock_stripe_subscription_schedule)
    mock_stripe_subscription_item = instance_double(Stripe::SubscriptionItem)
    # rubocop:disable RSpec/VerifiedDoubles
    allow(mock_stripe_subscription_item).to receive_messages(id: 'si_test123', price: double('price', id: 'price_test123'))
    allow(Stripe::SubscriptionItem).to receive(:list).and_return(double('list', data: [mock_stripe_subscription_item]))
    # rubocop:enable RSpec/VerifiedDoubles
  end
  # rubocop:enable  Metrics/AbcSize
end

RSpec.shared_examples 'returns error response' do |status, code|
  it "returns #{status} and error code #{code}" do
    is_expected.to eq status
    expect(body_hash[:error][:code]).to eq(code) if code

  end
end

RSpec.describe '[ credit card payments API ]' do
  describe 'POST /api/v1/internal/membership/contracts/credit_card_payments' do
    include_context 'membership and stripe setup'
    include_context 'stripe api mocks'

    context 'when no session' do
      let(:params) { { memberships_contracts: { membership_plan_id: leveled_membership_plan_platinum.id } } }

      it 'returns 401 Unauthorized' do
        is_expected.to eq 401
      end
    end

    context 'when success case' do
      include_context 'current user session is present'

      before do
        current_user.update!(payment_customer_id: 'cus_test123')
        allow(current_user).to receive(:valid_stripe_card_payment_method).and_return(current_user_stripe_payment_method)
        mock_stripe_apis
      end

      context 'valid credit card payment' do
        let(:params) { { memberships_contracts: { membership_plan_id: leveled_membership_plan_platinum.id } } }

        it 'creates a new membership contract' do
          expect {
            is_expected.to eq 201
          }.to change(Membership::Contract, :count).by(1)
            .and change(Payment::Transaction, :count).by(1)
            .and change(Membership::User, :count).by(leveled_membership_plan_platinum.memberships.count)
          json_response = response.parsed_body
          expect(json_response['id']).to be_present
          expect(json_response['status']).to eq('pending')
          expect(json_response['payment_transactions']).to be_present
          expect(json_response['payment_transactions'].first['payment_type']).to eq('credit_card')
          expect(json_response['payment_transactions'].first['payment_provider']).to eq('stripe')
        end

        it 'creates memberships_user with correct status' do
          is_expected.to eq 201

          contract = Membership::Contract.find(body_hash['id'])
          memberships_users = contract.membership_users

          expect(memberships_users.count).to eq(leveled_membership_plan_platinum.memberships.count)
          memberships_users.each do |membership_user|
            expect(membership_user.status).to eq('pending')
            expect(membership_user.user).to eq(current_user)
            expect(membership_user.membership_contract).to eq(contract)
          end
        end

        it 'creates memberships_contract with correct attributes' do
          is_expected.to eq 201

          contract = Membership::Contract.last
          expect(contract.user).to eq(current_user)
          expect(contract.status).to eq('pending')
        end

        it 'creates memberships_contract_term with correct attributes' do
          is_expected.to eq 201

          contract = Membership::Contract.find(body_hash['id'])
          contract_term = contract.current_contract_term
          expect(contract_term.user).to eq(current_user)
          expect(contract_term.membership_plan).to eq(leveled_membership_plan_platinum)
        end

        it 'returns correct response format' do
          is_expected.to eq 201
          json_response = response.parsed_body
          expect(json_response).to include('id', 'status', 'created_at', 'updated_at', 'payment_transactions')
          expect(json_response['payment_transactions']).to be_an(Array)
          expect(json_response['payment_transactions'].first).to include('id', 'payment_type', 'payment_provider', 'membership_contract_id')
        end
      end

      context 'payment with different plans' do
        context 'premium plan' do
          let(:params) { { memberships_contracts: { membership_plan_id: leveled_membership_plan_premium.id } } }

          it 'creates contract for premium plan' do
            is_expected.to eq 201
            json_response = response.parsed_body
            expect(json_response['status']).to eq('pending')
          end
        end

        context 'basic plan' do
          let(:params) { { memberships_contracts: { membership_plan_id: leveled_membership_plan_basic.id } } }

          it 'creates contract for basic plan' do
            is_expected.to eq 201
            json_response = response.parsed_body
            expect(json_response['status']).to eq('pending')
          end
        end
      end

      context 'plan with trial period' do
        let(:trial_plan) {
          create(:membership_plan, tenant_id: current_tenant.id, name: 'trial_plan', recurring_interval_count: 1, recurring_interval_unit: 'month', trial_period_days: 7, position: 4)
        }
        let(:params) { { memberships_contracts: { membership_plan_id: trial_plan.id } } }
        let(:confirmation_secret) { nil }
        # rubocop:disable RSpec/VerifiedDoubles
        let(:pending_setup_intent_double) { double('pending_setup_intent', client_secret: 'seti_trial_test123_secret', id: 'seti_trial_test123', status: 'requires_action', usage: 'off_session') }
        let(:mock_trial_stripe_subscription) { double('Stripe::Subscription') }
        # rubocop:enable RSpec/VerifiedDoubles

        before do
          create(:membership_plan_payment_method, tenant_id: current_tenant.id, membership_plan: trial_plan, payment_type: 'credit_card', stripe_record_price: stripe_record_price_platinum,
is_active: true,)
          # Mock Stripe API for trial plan
          # rubocop:disable RSpec/VerifiedDoubles
          allow(mock_trial_stripe_subscription).to receive_messages(
            id: 'sub_trial_test123',
            status: 'trialing',
            trial_end: 7.days.from_now.to_i,
            trial_start: Time.current.to_i,
            current_period_start: Time.current.to_i,
            current_period_end: 1.month.from_now.to_i,
            items: double('items', data: [
              double('subscription_item', current_period_start: Time.current.to_i, current_period_end: 1.month.from_now.to_i),
            ],),
            latest_invoice: latest_invoice_double,
            pending_setup_intent: pending_setup_intent_double,
          )
          # rubocop:enable RSpec/VerifiedDoubles
          allow(Stripe::Subscription).to receive(:create).and_return(mock_trial_stripe_subscription)

          mock_trial_stripe_invoice = instance_double(Stripe::Invoice, id: 'in_trial_test123', status: :open, confirmation_secret:)
          allow(Stripe::Invoice).to receive(:retrieve).and_return(mock_trial_stripe_invoice)
        end

        it 'creates contract with trial period' do
          is_expected.to eq 201
          json_response = response.parsed_body
          expect(json_response['status']).to eq('pending')
        end

        it 'sets trial period in stripe subscription' do
          is_expected.to eq 201

          # Stripe APIがtrial_period_daysで呼ばれることを確認
          expect(Stripe::Subscription).to have_received(:create).with(
            hash_including(trial_period_days: 7),
            anything,
          )
        end

        it 'includes pending_setup_intent in response body' do
          is_expected.to eq 201


          contract = Membership::Contract.find(body_hash['id'])
          contract.payment_transactions.first.chargeable

          expect(body_hash['payment_transactions'][0]['chargeable']['client_secret']).to be_present
        end
      end

      context 'trial history restriction' do
        let(:trial_plan) {
          create(:membership_plan, tenant_id: current_tenant.id, name: 'trial_plan', recurring_interval_count: 1, recurring_interval_unit: 'month', trial_period_days: 7, position: 4)
        }
        let(:trial_plan_component) {
          create(:membership_plan_component, tenant_id: current_tenant.id, membership_plan: trial_plan, membership: leveled_membership_platinum)
        }
        let(:params) { { memberships_contracts: { membership_plan_id: trial_plan.id } } }

        let(:trial_history) {
          create(:stripe_record_trial_history,
                 user: current_user,
                 tenant_id: current_tenant.id,
                 membership: trial_plan.memberships.first,
                 membership_plan: trial_plan,
                 fingerprint: 'test_card_fingerprint',)
        }

        before do
          trial_plan_component
          trial_history
          create(:membership_plan_payment_method, tenant_id: current_tenant.id, membership_plan: trial_plan, payment_type: 'credit_card', stripe_record_price: stripe_record_price_platinum,
is_active: true,)

          # トライアルなしのsubscriptionをモック
          # rubocop:disable RSpec/VerifiedDoubles
          mock_no_trial_subscription_item = double('subscription_item', current_period_start: Time.current.to_i, current_period_end: 1.month.from_now.to_i)
          mock_no_trial_items = double('items', data: [mock_no_trial_subscription_item])
          mock_no_trial_latest_invoice = double('latest_invoice', id: 'in_no_trial_test123')
          mock_no_trial_stripe_subscription = double('Stripe::Subscription')
          # rubocop:enable RSpec/VerifiedDoubles
          allow(mock_no_trial_stripe_subscription).to receive_messages(
            id: 'sub_no_trial_test123',
            status: 'incomplete',
            trial_end: nil,
            trial_start: nil,
            current_period_start: Time.current.to_i,
            current_period_end: 1.month.from_now.to_i,
            items: mock_no_trial_items,
            latest_invoice: mock_no_trial_latest_invoice,
            pending_setup_intent: nil,
          )
          allow(Stripe::Subscription).to receive(:create).and_return(mock_no_trial_stripe_subscription)
        end

        it 'creates contract without trial period for user with trial history' do
          is_expected.to eq 201
          json_response = response.parsed_body
          expect(json_response['status']).to eq('pending')
        end

        it 'does not set trial_period_days for user with trial history' do
          is_expected.to eq 201

          # Stripe APIがtrial_period_daysなしで呼ばれることを確認
          expect(Stripe::Subscription).to have_received(:create).with(
            hash_not_including(:trial_period_days),
            anything,
          )
        end

        it 'checks trial availability using card fingerprint' do
          is_expected.to eq 201

          # トライアル履歴が存在することを確認
          expect(StripeRecord::TrialHistory.exists?(membership: trial_plan.memberships, fingerprint: 'test_card_fingerprint')).to be true
        end
      end
    end

    context 'when error case' do
      include_context 'current user session is present'
      before do
        current_user.update!(payment_customer_id: 'cus_test123')
        allow(current_user).to receive(:valid_stripe_card_payment_method).and_return(current_user_stripe_payment_method)
        mock_stripe_apis
      end

      context 'invalid parameter' do
        context 'membership_plan_id is not given' do
          let(:params) { { memberships_contracts: {} } }

          it 'returns 400 Bad Request' do
            is_expected.to eq 400
          end
        end

        context 'membership_plan_id is not found' do
          let(:params) { { memberships_contracts: { membership_plan_id: 'invalid' } } }

          it 'returns 404 Not Found' do
            is_expected.to eq 404
          end
        end
      end

      context 'already have membership contract' do
        let(:params) { { memberships_contracts: { membership_plan_id: leveled_membership_plan_platinum.id } } }
        let(:existing_contract) {
          create(:membership_contract, tenant_id: current_tenant.id, user: current_user, status: 'pending')
        }
        let(:existing_transaction) {
          create(:payment__transaction, tenant_id: current_tenant.id, user: current_user, membership_contract: existing_contract,
payment_type: 'credit_card', payment_provider: 'stripe', external_id: 'dummy_external_id', chargeable: existing_stripe_record_subscription, status: 'pending', recurrence: true,)
        }
        let(:existing_stripe_record_subscription) {
          create(:stripe_record_subscription, tenant_id: current_tenant.id, user: current_user, price: stripe_record_price_platinum, product: stripe_record_product_platinum, status: :incomplete,
remote_id: 'dummy_subscription_remote_id', trial_end: nil, trial_start: nil, current_period_start: 1.month.ago, current_period_end: 1.month.from_now,)
        }
        let(:existing_membership_user) {
          create(:membership_user, tenant_id: current_tenant.id, user: current_user, status: 'pending', membership: leveled_membership_platinum, membership_contract: existing_contract)
        }

        before do
          existing_membership_user
          existing_stripe_record_subscription
        end

        it 'returns 400 Bad Request with already_have_membership error' do
          is_expected.to eq 400
          expect(body_hash[:error][:code]).to eq('already_have_membership')
        end

        it 'does not create new contract when already have membership' do
          expect {
            is_expected.to eq 400
          }.not_to change(Membership::Contract, :count)
        end
      end

      context 'same membership group contract' do
        let(:params) { { memberships_contracts: { membership_plan_id: leveled_membership_plan_platinum.id } } }
        let(:existing_contract) {
          create(:membership_contract, tenant_id: current_tenant.id, user: current_user, status: 'pending')
        }
        let(:existing_transaction) {
          create(:payment__transaction, tenant_id: current_tenant.id, user: current_user, membership_contract: existing_contract,
payment_type: 'credit_card', payment_provider: 'stripe', external_id: 'dummy_external_id', chargeable: existing_stripe_record_subscription, status: 'pending', recurrence: true,)
        }
        let(:existing_stripe_record_subscription) {
          create(:stripe_record_subscription, tenant_id: current_tenant.id, user: current_user, price: stripe_record_price_platinum, product: stripe_record_product_platinum, status: :incomplete,
remote_id: 'dummy_subscription_remote_id', trial_end: nil, trial_start: nil, current_period_start: 1.month.ago, current_period_end: 1.month.from_now,)
        }
        let(:existing_membership_user) {
          create(:membership_user, tenant_id: current_tenant.id, user: current_user, status: 'pending', membership: leveled_membership_platinum, membership_contract: existing_contract)
        }


        before do
          existing_membership_user
          existing_stripe_record_subscription
        end

        it 'returns 400 Bad Request with already_have_membership error for same group' do
          is_expected.to eq 400
          expect(body_hash[:error][:code]).to eq('already_have_membership')
        end

        it 'does not create new contract for same membership group' do
          expect {
            is_expected.to eq 400
          }.not_to change(Membership::Contract, :count)
        end
      end

      context 'no credit card registered' do
        let(:params) { { memberships_contracts: { membership_plan_id: leveled_membership_plan_platinum.id } } }
        let(:current_user_stripe_payment_method) { nil }

        before do
          allow(current_user).to receive(:valid_stripe_card_payment_method).and_return(nil)
        end

        it 'returns 400 Bad Request with card_missing error' do
          is_expected.to eq 400
          expect(body_hash[:error][:code]).to eq('card_missing')
        end

        it 'does not create contract when no credit card' do
          expect {
            is_expected.to eq 400
          }.not_to change(Membership::Contract, :count)
        end
      end

      context 'plan does not support credit card payment' do
        let(:membership_plan_payment_method_platinum) { nil }
        let(:params) { { memberships_contracts: { membership_plan_id: leveled_membership_plan_platinum.id } } }

        it 'returns 400 Bad Request with payment_method_not_available error' do
          is_expected.to eq 400
          expect(body_hash[:error][:code]).to eq('payment_method_not_available')
        end
      end

      context 'Stripe API error' do
        let(:params) { { memberships_contracts: { membership_plan_id: leveled_membership_plan_platinum.id } } }

        before do
          allow(Stripe::Subscription).to receive(:create).and_raise(Stripe::CardError.new('Your card was declined.', 'card_declined'))
        end

        it 'returns 400 Bad Request with stripe_error' do
          is_expected.to eq 400
          expect(body_hash[:error][:code]).to eq('stripe_error')
        end

        it 'does not create contract when Stripe API fails' do
          expect {
            is_expected.to eq 400
          }.not_to change(Membership::Contract, :count)
        end

        it 'captures exception in Sentry when Stripe API fails' do
          allow(Sentry).to receive(:capture_exception)
          is_expected.to eq 400
          expect(Sentry).to have_received(:capture_exception).with(instance_of(Stripe::CardError))
        end
      end

      context 'database error' do
        let(:params) { { memberships_contracts: { membership_plan_id: leveled_membership_plan_platinum.id } } }

        before do
          allow(Membership::Contract).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Membership::Contract.new))
        end

        it 'returns 400 Bad Request with validation_error' do
          is_expected.to eq 400
          expect(body_hash[:error][:code]).to eq('validation_error')
        end
      end
    end

    context 'edge cases' do
      include_context 'current user session is present'
      before do
        current_user.update!(payment_customer_id: 'cus_test123')
        allow(current_user).to receive(:valid_stripe_card_payment_method).and_return(current_user_stripe_payment_method)
        mock_stripe_apis
      end

      context 'inactive plan' do
        let(:inactive_plan) {
          create(:membership_plan, tenant_id: current_tenant.id, name: 'inactive_plan', recurring_interval_count: 1, recurring_interval_unit: 'month', is_active: false, position: 6)
        }
        let(:params) { { memberships_contracts: { membership_plan_id: inactive_plan.id } } }

        it 'returns 400 Bad Request with payment_method_not_available error' do
          is_expected.to eq 400
          expect(body_hash[:error][:code]).to eq('payment_method_not_available')
        end
      end

      context 'plan from another tenant' do
        let(:other_tenant) { create(:tenant, id: 'other', name: 'other_tenant') }
        let(:other_plan) {
          create(:membership_plan, tenant_id: other_tenant.id, name: 'other_plan', recurring_interval_count: 1, recurring_interval_unit: 'month', position: 7)
        }
        let(:params) { { memberships_contracts: { membership_plan_id: other_plan.id } } }

        it 'cannot access plan from another tenant' do
          is_expected.to eq 404
        end
      end
    end
  end

  describe 'POST /api/v1/internal/membership/contracts/credit_card_payments/:contract_id/complete' do
    include_context 'membership and stripe setup'
    include_context 'stripe api mocks'
    let(:tenant_stripe_account) { create(:tenant_stripe_account, :with_account, tenant_id: current_tenant.id) }
    let(:contract) { create(:membership_contract, tenant_id: current_tenant.id, user: current_user, status: 'pending') }
    let(:stripe_record_subscription) { create(:stripe_record_subscription, tenant_id: current_tenant.id, user: current_user, price: stripe_record_price_platinum) }
    let(:payment_subscription) { create(:payment__subscription, tenant_id: current_tenant.id, user: current_user, membership_contract: contract, subscribable: stripe_record_subscription) }
    let(:payment_transaction) {
      create(:payment__transaction, tenant_id: current_tenant.id, user: current_user, membership_contract: contract, payment_type: 'credit_card', payment_provider: 'stripe', external_id: 'pi_test123',
     chargeable: stripe_record_payment_intent, status: 'pending', recurrence: true,)
    }
    let(:stripe_record_invoice) { create(:stripe_record_invoice, tenant_id: current_tenant.id, user: current_user) }
    let(:stripe_record_payment_intent) {
      create(:stripe_record_payment_intent, tenant_id: current_tenant.id, user: current_user, remote_id: 'pi_test123', status: 'requires_confirmation', invoice: stripe_record_invoice,
     api_key_account: tenant_stripe_account.stripe_account,)
    }
    let(:contract_term) { create(:membership_contract_term, tenant_id: current_tenant.id, user: current_user, membership_contract: contract, membership_plan: leveled_membership_plan_platinum) }

    before do
      tenant_stripe_account
      contract_term
      payment_subscription
      payment_transaction
      stripe_record_payment_intent
    end

    context 'when no session' do
      let(:contract_id) { contract.id }

      it 'returns 401 Unauthorized' do
        is_expected.to eq 401
      end
    end

    context 'when success case' do
      include_context 'current user session is present'

      let(:contract_id) { contract.id }

      before do
        # Mock Stripe API for PaymentIntent refresh
        mock_stripe_payment_intent = Stripe::PaymentIntent.construct_from({
          id: 'pi_test123',
          status: 'succeeded',
          amount: 500,
          currency: 'jpy',
          customer: 'cus_test123',
          payment_method: 'pm_test123',
          created: Time.current.to_i,
          canceled_at: nil,
          confirmation_method: 'automatic',
          capture_method: 'automatic',
          client_secret: 'pi_test123_secret',
        })
        allow(StripeRecord::Client::PaymentIntent).to receive(:retrieve).and_return(Mangrove::Result.ok(mock_stripe_payment_intent))

        # Mock Stripe API for Subscription refresh
        mock_stripe_subscription = instance_double(Stripe::Subscription)

        # Mock items.data.first.current_period_end
        # rubocop:disable RSpec/VerifiedDoubles
        mock_subscription_item = double('Stripe::SubscriptionItem')
        allow(mock_subscription_item).to receive(:current_period_end).and_return(1.month.from_now.to_i)
        mock_items = double('Stripe::ListObject')
        allow(mock_items).to receive(:data).and_return([mock_subscription_item])
        # rubocop:enable RSpec/VerifiedDoubles
        allow(mock_stripe_subscription).to receive_messages(id: 'sub_test123', status: 'active', items: mock_items)

        allow(Stripe::Subscription).to receive(:retrieve).and_return(mock_stripe_subscription)
      end

      it 'completes the contract successfully' do
        expect {
          is_expected.to eq 200
        }.to change { contract.reload.status }.from('pending').to('active')
          .and change { payment_transaction.reload.status }.from('pending').to('active')
          .and change { contract.reload.expires_at }.from(nil).to(be_within(1.second).of(1.month.from_now))

        json_response = response.parsed_body
        expect(json_response['id']).to eq(contract.id)
        expect(json_response['status']).to eq('active')
        expect(json_response['expires_at']).to be_present
      end

      it 'creates active membership users' do
        is_expected.to eq 200

        contract.reload
        membership_users = contract.membership_users
        expect(membership_users.count).to eq(leveled_membership_plan_platinum.memberships.count)
        membership_users.each do |membership_user|
          expect(membership_user.status).to eq('active')
          expect(membership_user.expires_at).to be_present
        end
      end

      it 'returns correct response format' do
        is_expected.to eq 200
        json_response = response.parsed_body
        expect(json_response).to include('id', 'status', 'created_at', 'updated_at', 'expires_at')
        expect(json_response['status']).to eq('active')
      end
    end

    context 'when error case' do
      include_context 'current user session is present'

      let(:contract_id) { contract.id }

      context 'contract not found' do
        let(:contract_id) { 'invalid-id' }

        it 'returns 404 Not Found' do
          is_expected.to eq 404
        end
      end

      context 'transaction not found' do
        before do
          payment_transaction.destroy!
        end

        it 'returns 400 Bad Request with transaction_not_found error' do
          is_expected.to eq 400
          expect(body_hash[:error][:code]).to eq('transaction_not_found')
        end
      end

      context 'payment not succeeded' do
        before do
          stripe_record_payment_intent.update!(status: 'requires_action')

          # Mock Stripe API for PaymentIntent refresh
          mock_stripe_payment_intent = Stripe::PaymentIntent.construct_from({
            id: 'pi_test123',
            status: 'requires_action',
            amount: 500,
            currency: 'jpy',
            customer: 'cus_test123',
            payment_method: 'pm_test123',
            created: Time.current.to_i,
            canceled_at: nil,
            confirmation_method: 'automatic',
            capture_method: 'automatic',
            client_secret: 'pi_test123_secret',
          })
          allow(StripeRecord::Client::PaymentIntent).to receive(:retrieve).and_return(Mangrove::Result.ok(mock_stripe_payment_intent))
        end

        it 'returns 400 Bad Request with payment_not_succeeded error' do
          is_expected.to eq 400
          expect(body_hash[:error][:code]).to eq('payment_not_succeeded')
        end
      end

      context 'stripe API error' do
        before do
          allow(StripeRecord::Client::PaymentIntent).to receive(:retrieve).and_return(Mangrove::Result.err(Stripe::CardError.new('Card was declined', 'card_declined')))
        end

        it 'returns 400 Bad Request with stripe_error' do
          is_expected.to eq 400
          expect(body_hash[:error][:code]).to eq('stripe_error')
        end
      end

      context 'unsupported chargeable type' do
        before do
          # 他の決済のchargeableが紐づいていた場合
          payment_transaction.update!(chargeable: nil)
        end

        it 'returns 400 Bad Request with unsupported_chargeable error' do
          is_expected.to eq 400
          expect(body_hash[:error][:code]).to eq('unsupported_chargeable')
        end
      end
    end

    context 'with SetupIntent' do
      include_context 'current user session is present'

      let(:stripe_record_setup_intent) {
        create(:stripe_record_setup_intent, tenant_id: current_tenant.id, user: current_user, remote_id: 'seti_test123', status: 'requires_action',
api_key_account: tenant_stripe_account.stripe_account,)
      }
      let(:payment_transaction_setup) {
        create(:payment__transaction,
               tenant_id: current_tenant.id,
               user: current_user,
               membership_contract: contract,
               payment_type: 'credit_card',
               payment_provider: 'stripe',
               external_id: 'seti_test123',
               chargeable: stripe_record_setup_intent,
               status: 'pending',
               recurrence: true,)
      }
      let(:contract_id) { contract.id }

      before do
        payment_transaction.destroy!
        payment_transaction_setup
        stripe_record_setup_intent

        # Mock Stripe API for SetupIntent refresh
        mock_stripe_setup_intent = Stripe::SetupIntent.construct_from({
          id: 'seti_test123',
          status: 'succeeded',
          usage: 'off_session',
          client_secret: 'seti_test123_secret',
        })
        allow(StripeRecord::Client::SetupIntent).to receive(:retrieve).and_return(Mangrove::Result.ok(mock_stripe_setup_intent))

        # Mock Stripe API for Subscription refresh
        mock_stripe_subscription = instance_double(Stripe::Subscription)

        # Mock items.data.first.current_period_end
        # rubocop:disable RSpec/VerifiedDoubles
        mock_subscription_item = double('Stripe::SubscriptionItem')
        allow(mock_subscription_item).to receive(:current_period_end).and_return(1.month.from_now.to_i)
        mock_items = double('Stripe::ListObject')
        allow(mock_items).to receive(:data).and_return([mock_subscription_item])
        # rubocop:enable RSpec/VerifiedDoubles
        allow(mock_stripe_subscription).to receive_messages(id: 'sub_test123', status: 'active', items: mock_items)

        allow(Stripe::Subscription).to receive(:retrieve).and_return(mock_stripe_subscription)
      end

      it 'completes the contract successfully with SetupIntent' do
        expect {
          is_expected.to eq 200
        }.to change { contract.reload.status }.from('pending').to('active')
          .and change { payment_transaction_setup.reload.status }.from('pending').to('active')

        json_response = response.parsed_body
        expect(json_response['status']).to eq('active')
      end
    end
  end
end
