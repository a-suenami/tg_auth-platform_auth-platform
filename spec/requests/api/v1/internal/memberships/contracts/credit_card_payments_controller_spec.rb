# typed: false


# --- Shared Contexts & Examples ---
RSpec.shared_context 'membership and stripe setup' do
  let(:current_user) {
    create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'Password1234!')
  }
  let(:leveled_membership_group) { create(:memberships__group, :with_leveled_memberships, tenant_id: current_tenant.id, name: 'leveled_membership_group') }
  let(:leveled_membership_platinum) { leveled_membership_group.memberships.find_by(name: 'platinum') }
  let(:leveled_membership_premium) { leveled_membership_group.memberships.find_by(name: 'premium') }
  let(:leveled_membership_basic) { leveled_membership_group.memberships.find_by(name: 'basic') }
  let(:stripe_record_product_platinum) { create(:stripe_record_product, tenant_id: current_tenant.id, name: 'platinum_product') }
  let(:stripe_record_product_premium) { create(:stripe_record_product, tenant_id: current_tenant.id, name: 'premium_product') }
  let(:stripe_record_product_basic) { create(:stripe_record_product, tenant_id: current_tenant.id, name: 'basic_product') }
  let(:leveled_membership_plan_platinum) {
    create(:memberships__plan, tenant_id: current_tenant.id, name: 'platinum_plan', recurring_interval_count: 1, recurring_interval_unit: 'month', position: 1, amount: 5000)
  }
  let(:leveled_membership_plan_premium) {
    create(:memberships__plan, tenant_id: current_tenant.id, name: 'premium_plan', recurring_interval_count: 1, recurring_interval_unit: 'month', position: 2, amount: 3000)
  }
  let(:leveled_membership_plan_basic) {
    create(:memberships__plan, tenant_id: current_tenant.id, name: 'basic_plan', recurring_interval_count: 1, recurring_interval_unit: 'month', position: 3, amount: 1000)
  }
  let(:stripe_record_price_platinum) {
    create(:stripe_record_price, tenant_id: current_tenant.id, product: stripe_record_product_platinum, amount: leveled_membership_plan_platinum.amount)
  }
  let(:stripe_record_price_premium) { create(:stripe_record_price, tenant_id: current_tenant.id, product: stripe_record_product_premium, amount: leveled_membership_plan_premium.amount) }
  let(:stripe_record_price_basic) { create(:stripe_record_price, tenant_id: current_tenant.id, product: stripe_record_product_basic, amount: leveled_membership_plan_basic.amount) }
  let(:membership_plan_payment_method_platinum) {
    create(:memberships__plan_payment_method, tenant_id: current_tenant.id, membership_plan: leveled_membership_plan_platinum, payment_type: 'credit_card',
stripe_record_price: stripe_record_price_platinum, is_active: true,)
  }
  let(:membership_plan_payment_method_premium) {
    create(:memberships__plan_payment_method, tenant_id: current_tenant.id, membership_plan: leveled_membership_plan_premium, payment_type: 'credit_card',
stripe_record_price: stripe_record_price_premium, is_active: true,)
  }
  let(:membership_plan_payment_method_basic) {
    create(:memberships__plan_payment_method, tenant_id: current_tenant.id, membership_plan: leveled_membership_plan_basic, payment_type: 'credit_card',
stripe_record_price: stripe_record_price_basic, is_active: true,)
  }
  let(:membership_plan_component_platinum) {
    create(:memberships__plan_component, tenant_id: current_tenant.id, membership_plan: leveled_membership_plan_platinum, membership: leveled_membership_platinum)
  }
  let(:membership_plan_component_premium) {
    create(:memberships__plan_component, tenant_id: current_tenant.id, membership_plan: leveled_membership_plan_premium, membership: leveled_membership_premium)
  }
  let(:membership_plan_component_basic) {
    create(:memberships__plan_component, tenant_id: current_tenant.id, membership_plan: leveled_membership_plan_basic, membership: leveled_membership_basic)
  }
  let(:contract) { create(:memberships__contract, tenant_id: current_tenant.id, user: current_user, membership_plan: leveled_membership_plan_platinum) }
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
  def mock_stripe_apis
    # rubocop:disable RSpec/VerifiedDoubles
    mock_stripe_card = Stripe::Card.new
    allow(mock_stripe_card).to receive(:fingerprint).and_return('test_card_fingerprint')
    mock_stripe_payment_method = Stripe::PaymentMethod.new
    allow(mock_stripe_payment_method).to receive(:card).and_return(mock_stripe_card)
    mock_stripe_customer = Stripe::Customer.new
    allow(mock_stripe_customer).to receive_messages(invoice_settings: double('invoice_settings', default_payment_method: mock_stripe_payment_method), default_source: nil)
    allow(Stripe::Customer).to receive(:retrieve).and_return(mock_stripe_customer)
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
      latest_invoice: double('latest_invoice', id: 'in_test123'),
      pending_setup_intent: nil,
    )
    allow(Stripe::Subscription).to receive_messages(create: mock_stripe_subscription, retrieve: mock_stripe_subscription, update: mock_stripe_subscription)
    mock_stripe_invoice = double('Stripe::Invoice')
    allow(mock_stripe_invoice).to receive_messages(id: 'in_test123', status: 'open', confirmation_secret: double('confirmation_secret', client_secret: 'pi_test123_secret'))
    allow(Stripe::Invoice).to receive(:retrieve).and_return(mock_stripe_invoice)
    mock_stripe_setup_intent = double('Stripe::SetupIntent')
    allow(mock_stripe_setup_intent).to receive_messages(id: 'seti_test123', status: 'requires_payment_method', usage: 'off_session', client_secret: 'seti_test123_secret')
    allow(Stripe::SetupIntent).to receive(:retrieve).and_return(mock_stripe_setup_intent)
    mock_stripe_payment_method = double('Stripe::PaymentMethod')
    allow(mock_stripe_payment_method).to receive(:card).and_return(double('card', fingerprint: 'test_fingerprint'))
    allow(Stripe::PaymentMethod).to receive(:retrieve).and_return(mock_stripe_payment_method)
    mock_stripe_card = double('Stripe::Card')
    allow(mock_stripe_card).to receive(:fingerprint).and_return('test_fingerprint')
    allow(Stripe::Card).to receive(:retrieve).and_return(mock_stripe_card)
    mock_stripe_account = double('Stripe::Account')
    allow(mock_stripe_account).to receive_messages(id: 'acct_test123', type: 'standard', display_name: 'Test Account')
    allow(Stripe::Account).to receive(:retrieve).and_return(mock_stripe_account)
    mock_stripe_subscription_schedule = double('Stripe::SubscriptionSchedule')
    allow(mock_stripe_subscription_schedule).to receive_messages(id: 'sub_sched_test123', status: 'active',
current_phase: double('current_phase', start_date: Time.current.to_i, end_date: 1.month.from_now.to_i),)
    allow(Stripe::SubscriptionSchedule).to receive_messages(retrieve: mock_stripe_subscription_schedule, create: mock_stripe_subscription_schedule, update: mock_stripe_subscription_schedule)
    mock_stripe_subscription_item = double('Stripe::SubscriptionItem')
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
  describe 'POST /api/v1/internal/memberships/contracts/credit_card_payments' do
    include_context 'membership and stripe setup'
    include_context 'stripe api mocks'

    context 'when no session' do
      let(:params) { { memberships_contracts: { memberships_plan_id: leveled_membership_plan_platinum.id } } }

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
        let(:params) { { memberships_contracts: { memberships_plan_id: leveled_membership_plan_platinum.id } } }

        it 'creates a new membership contract' do
          expect {
            is_expected.to eq 201
          }.to change(Memberships::Contract, :count).by(1)
            .and change(Memberships::BillingProfile, :count).by(1)
            .and change(Memberships::User, :count).by(leveled_membership_plan_platinum.memberships.count)
          json_response = response.parsed_body
          expect(json_response['id']).to be_present
          expect(json_response['status']).to eq('pending')
          expect(json_response['billing_profiles']).to be_present
          expect(json_response['billing_profiles'].first['payment_type']).to eq('credit_card')
          expect(json_response['billing_profiles'].first['payment_provider']).to eq('stripe')
        end

        it 'returns correct response format' do
          is_expected.to eq 201
          json_response = response.parsed_body
          expect(json_response).to include('id', 'status', 'created_at', 'updated_at', 'billing_profiles')
          expect(json_response['billing_profiles']).to be_an(Array)
          expect(json_response['billing_profiles'].first).to include('id', 'payment_type', 'payment_provider', 'membership_plan_id')
        end
      end

      context 'payment with different plans' do
        context 'premium plan' do
          let(:params) { { memberships_contracts: { memberships_plan_id: leveled_membership_plan_premium.id } } }

          it 'creates contract for premium plan' do
            is_expected.to eq 201
            json_response = response.parsed_body
            expect(json_response['status']).to eq('pending')
          end
        end

        context 'basic plan' do
          let(:params) { { memberships_contracts: { memberships_plan_id: leveled_membership_plan_basic.id } } }

          it 'creates contract for basic plan' do
            is_expected.to eq 201
            json_response = response.parsed_body
            expect(json_response['status']).to eq('pending')
          end
        end
      end

      context 'plan with trial period' do
        let(:trial_plan) {
          create(:memberships__plan, tenant_id: current_tenant.id, name: 'trial_plan', recurring_interval_count: 1, recurring_interval_unit: 'month', trial_period_days: 7, position: 4)
        }
        let(:params) { { memberships_contracts: { memberships_plan_id: trial_plan.id } } }

        before do
          create(:memberships__plan_payment_method, tenant_id: current_tenant.id, membership_plan: trial_plan, payment_type: 'credit_card', stripe_record_price: stripe_record_price_platinum,
is_active: true,)
          # rubocop:disable RSpec/VerifiedDoubles
          # Mock Stripe API for trial plan
          mock_trial_stripe_subscription = double('Stripe::Subscription')
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
            latest_invoice: double('latest_invoice', id: 'in_trial_test123'),
            pending_setup_intent: nil,
          )
          allow(Stripe::Subscription).to receive(:create).and_return(mock_trial_stripe_subscription)
          # rubocop:enable RSpec/VerifiedDoubles
        end

        it 'creates contract with trial period' do
          is_expected.to eq 201
          json_response = response.parsed_body
          expect(json_response['status']).to eq('pending')
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
        context 'memberships_plan_id is not given' do
          let(:params) { { memberships_contracts: {} } }

          it 'returns 400 Bad Request' do
            is_expected.to eq 400
          end
        end

        context 'memberships_plan_id is not found' do
          let(:params) { { memberships_contracts: { memberships_plan_id: 'invalid' } } }

          it 'returns 404 Not Found' do
            is_expected.to eq 404
          end
        end
      end

      context 'already have membership contract' do
        let(:params) { { memberships_contracts: { memberships_plan_id: leveled_membership_plan_platinum.id } } }
        let(:existing_contract) {
          create(:memberships__contract, tenant_id: current_tenant.id, user: current_user, status: 'pending')
        }
        let(:existing_billing_profile) {
          create(:memberships__billing_profile, tenant_id: current_tenant.id, user: current_user, membership_plan: leveled_membership_plan_platinum, membership_contract: existing_contract,
payment_type: 'credit_card', payment_provider: 'stripe', external_id: 'dummy_external_id', chargeable: existing_stripe_record_subscription, status: 'pending', recurrence: true,)
        }
        let(:existing_stripe_record_subscription) {
          create(:stripe_record_subscription, tenant_id: current_tenant.id, user: current_user, price: stripe_record_price_platinum, product: stripe_record_product_platinum, status: :incomplete,
remote_id: 'dummy_subscription_remote_id', trial_end: nil, trial_start: nil, current_period_start: 1.month.ago, current_period_end: 1.month.from_now,)
        }
        let(:existing_membership_user) {
          create(:memberships__user, tenant_id: current_tenant.id, user: current_user, status: 'pending', membership: leveled_membership_platinum, membership_contract: existing_contract)
        }

        before do
          existing_membership_user
          existing_billing_profile
          existing_stripe_record_subscription
        end

        it 'returns 400 Bad Request with already_have_membership error' do
          is_expected.to eq 400
          expect(body_hash[:error][:code]).to eq('already_have_membership')
        end
      end

      context 'no credit card registered' do
        let(:params) { { memberships_contracts: { memberships_plan_id: leveled_membership_plan_platinum.id } } }
        let(:current_user_stripe_payment_method) { nil }

        before do
          allow(current_user).to receive(:valid_stripe_card_payment_method).and_return(nil)
        end

        it 'returns 400 Bad Request with card_missing error' do
          is_expected.to eq 400
          expect(body_hash[:error][:code]).to eq('card_missing')
        end
      end

      context 'plan does not support credit card payment' do
        let(:membership_plan_payment_method_platinum) { nil }
        let(:params) { { memberships_contracts: { memberships_plan_id: leveled_membership_plan_platinum.id } } }

        it 'returns 400 Bad Request with payment_method_not_available error' do
          is_expected.to eq 400
          expect(body_hash[:error][:code]).to eq('payment_method_not_available')
        end
      end

      context 'Stripe API error' do
        let(:params) { { memberships_contracts: { memberships_plan_id: leveled_membership_plan_platinum.id } } }

        before do
          allow(Stripe::Subscription).to receive(:create).and_raise(Stripe::CardError.new('Your card was declined.', 'card_declined'))
        end

        it 'returns 400 Bad Request with stripe_error' do
          is_expected.to eq 400
          expect(body_hash[:error][:code]).to eq('stripe_error')
        end
      end

      context 'database error' do
        let(:params) { { memberships_contracts: { memberships_plan_id: leveled_membership_plan_platinum.id } } }

        before do
          allow(Memberships::Contract).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Memberships::Contract.new))
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
          create(:memberships__plan, tenant_id: current_tenant.id, name: 'inactive_plan', recurring_interval_count: 1, recurring_interval_unit: 'month', is_active: false, position: 6)
        }
        let(:params) { { memberships_contracts: { memberships_plan_id: inactive_plan.id } } }

        it 'returns 400 Bad Request with payment_method_not_available error' do
          is_expected.to eq 400
          expect(body_hash[:error][:code]).to eq('payment_method_not_available')
        end
      end

      context 'plan from another tenant' do
        let(:other_tenant) { create(:tenant, id: 'other', name: 'other_tenant') }
        let(:other_plan) {
          create(:memberships__plan, tenant_id: other_tenant.id, name: 'other_plan', recurring_interval_count: 1, recurring_interval_unit: 'month', position: 7)
        }
        let(:params) { { memberships_contracts: { memberships_plan_id: other_plan.id } } }

        it 'cannot access plan from another tenant' do
          is_expected.to eq 404
        end
      end
    end
  end
end
