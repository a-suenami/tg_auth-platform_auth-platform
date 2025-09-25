# typed: false
# frozen_string_literal: true

RSpec.describe '[ API::V1::Internal::Memberships::ContractsController API ]' do
  # テスト用のメンバーシッププランとコンポーネント
  let!(:membership_group) { create(:memberships__group, tenant_id: current_tenant.id, name: 'test_group', position: 1) }
  let!(:membership) { create(:membership, tenant_id: current_tenant.id, membership_group:, name: 'test_membership', position: 1, tier: 1) }
  let!(:membership_plan) { create(:memberships__plan, tenant_id: current_tenant.id, name: 'test_plan', amount: 1000, position: 1, recurring_interval_count: 1, recurring_interval_unit: 'month') }
  let!(:membership_plan_component) { create(:memberships__plan_component, membership_plan:, membership:, tenant_id: current_tenant.id) }
  let!(:membership_plan_payment_method) { create(:memberships__plan_payment_method, membership_plan:, tenant_id: current_tenant.id, payment_type: 'credit_card', is_active: true) }

  # Stripe関連のレコード
  let!(:stripe_record_product) { create(:stripe_record_product, tenant_id: current_tenant.id, name: 'test_product') }
  let!(:stripe_record_price) { create(:stripe_record_price, tenant_id: current_tenant.id, product: stripe_record_product, amount: membership_plan.amount) }
  let!(:stripe_record_subscription) {
    create(:stripe_record_subscription, tenant_id: current_tenant.id, user: current_user, price: stripe_record_price, product: stripe_record_product, status: :active, remote_id: 'sub_test123')
  }

  # メンバーシップ契約
  let!(:active_contract) { create(:memberships__contract, tenant_id: current_tenant.id, user: current_user, status: 'active', expires_at: 1.year.from_now, cancel_at_period_end: false) }
  let!(:pending_contract) { create(:memberships__contract, :pending, tenant_id: current_tenant.id, user: current_user, expires_at: 1.year.from_now) }
  let!(:expired_contract) { create(:memberships__contract, :expired, tenant_id: current_tenant.id, user: current_user) }
  let!(:canceled_contract) { create(:memberships__contract, :canceled, tenant_id: current_tenant.id, user: current_user) }

  # 請求プロファイル
  let!(:active_billing_profile) {
    create(:memberships__billing_profile, tenant_id: current_tenant.id, user: current_user, membership_plan:, membership_contract: active_contract, payment_type: 'credit_card',
   payment_provider: 'stripe', external_id: 'sub_test123', chargeable: stripe_record_subscription, status: 'active', recurrence: true,)
  }
  let!(:pending_billing_profile) {
    create(:memberships__billing_profile, :pending, tenant_id: current_tenant.id, user: current_user, membership_plan:, membership_contract: pending_contract, payment_type: 'credit_card',
   payment_provider: 'stripe', external_id: 'sub_pending123', status: 'pending', recurrence: true,)
  }
  let!(:expired_billing_profile) {
    create(:memberships__billing_profile, :closed, tenant_id: current_tenant.id, user: current_user, membership_plan:, membership_contract: expired_contract, payment_type: 'credit_card',
   payment_provider: 'stripe', external_id: 'sub_expired123', status: 'expired', recurrence: false,)
  }

  # メンバーシップユーザー（同じユーザー、テナント、メンバーシップの組み合わせは重複不可）
  # 各契約に対応するmemberships__userを作成（異なるメンバーシップを使用）
  let!(:membership_for_pending) { create(:membership, tenant_id: current_tenant.id, membership_group:, name: 'pending_membership', position: 2, tier: 2) }
  let!(:membership_for_expired) { create(:membership, tenant_id: current_tenant.id, membership_group:, name: 'expired_membership', position: 3, tier: 3) }
  let!(:membership_for_canceled) { create(:membership, tenant_id: current_tenant.id, membership_group:, name: 'canceled_membership', position: 4, tier: 4) }

  let!(:active_membership_user) { create(:memberships__user, tenant_id: current_tenant.id, user: current_user, status: 'active', membership:, membership_contract: active_contract) }
  let!(:pending_membership_user) {
    create(:memberships__user, tenant_id: current_tenant.id, user: current_user, status: 'pending', membership: membership_for_pending, membership_contract: pending_contract)
  }
  let!(:expired_membership_user) {
    create(:memberships__user, tenant_id: current_tenant.id, user: current_user, status: 'expired', membership: membership_for_expired, membership_contract: expired_contract)
  }
  let!(:canceled_membership_user) {
    create(:memberships__user, tenant_id: current_tenant.id, user: current_user, status: 'canceled', membership: membership_for_canceled, membership_contract: canceled_contract)
  }

  before do
    # すべてのレコードを確実に作成
    membership_plan_component
    membership_plan_payment_method
    active_billing_profile
    pending_billing_profile
    expired_billing_profile
    active_membership_user
    pending_membership_user
    expired_membership_user
    canceled_membership_user
  end

  describe 'GET /api/v1/internal/memberships/contracts' do
    include_context 'current user session is present'

    it 'returns all contracts for current user' do
      is_expected.to eq 200

      expect(body_array.size).to eq 4

      # 契約の詳細確認
      active_contract_response = body_array.find { |contract| contract['id'] == active_contract.id }
      expect(active_contract_response).to be_present
      expect(active_contract_response['status']).to eq active_contract.status
      expect(active_contract_response['expires_at']).to eq active_contract.expires_at.iso8601
      expect(active_contract_response['cancel_at_period_end']).to eq active_contract.cancel_at_period_end
    end

    it 'returns contracts ordered by created_at desc' do
      is_expected.to eq 200

      # 作成日時の降順でソートされていることを確認
      created_at_times = body_array.pluck('created_at')
      expect(created_at_times).to eq created_at_times.sort.reverse
    end

    it 'includes billing profiles in contracts' do
      is_expected.to eq 200

      active_contract_response = body_array.find { |contract| contract['id'] == active_contract.id }
      expect(active_contract_response['billing_profiles']).to be_present
      expect(active_contract_response['billing_profiles'].size).to eq 1

      billing_profile = active_contract_response['billing_profiles'][0]
      expect(billing_profile['id']).to eq active_billing_profile.id
      expect(billing_profile['payment_type']).to eq active_billing_profile.payment_type
      expect(billing_profile['payment_provider']).to eq active_billing_profile.payment_provider
      expect(billing_profile['external_id']).to eq active_billing_profile.external_id
      expect(billing_profile['membership_plan_id']).to eq active_billing_profile.membership_plan_id
    end

    it 'includes chargeable subscription in billing profiles' do
      is_expected.to eq 200

      active_contract_response = body_array.find { |contract| contract['id'] == active_contract.id }
      billing_profile = active_contract_response['billing_profiles'][0]

      expect(billing_profile['chargeable']).to be_present
      expect(billing_profile['chargeable']['id']).to eq stripe_record_subscription.id
      expect(billing_profile['chargeable']['remote_id']).to eq stripe_record_subscription.remote_id
    end

    context 'when user has no contracts' do
      before do
        # 現在のユーザーの契約をすべて削除
        current_user.membership_contracts.destroy_all
      end

      it 'returns empty array' do
        is_expected.to eq 200

        expect(body_array.size).to eq 0
      end
    end
  end

  describe 'GET /api/v1/internal/memberships/contracts/:id' do
    include_context 'current user session is present'

    context 'when contract exists' do
      let(:id) { active_contract.id }

      it 'returns specific contract' do
        is_expected.to eq 200

        expect(body_hash['id']).to eq active_contract.id
        expect(body_hash['status']).to eq active_contract.status
        expect(body_hash['expires_at']).to eq active_contract.expires_at.iso8601
        expect(body_hash['cancel_at_period_end']).to eq active_contract.cancel_at_period_end
        expect(body_hash['created_at']).to eq active_contract.created_at.iso8601
        expect(body_hash['updated_at']).to eq active_contract.updated_at.iso8601
      end

      it 'includes billing profiles' do
        is_expected.to eq 200

        expect(body_hash['billing_profiles']).to be_present
        expect(body_hash['billing_profiles'].size).to eq 1

        billing_profile = body_hash['billing_profiles'][0]
        expect(billing_profile['id']).to eq active_billing_profile.id
        expect(billing_profile['payment_type']).to eq active_billing_profile.payment_type
        expect(billing_profile['payment_provider']).to eq active_billing_profile.payment_provider
        expect(billing_profile['external_id']).to eq active_billing_profile.external_id
        expect(billing_profile['membership_plan_id']).to eq active_billing_profile.membership_plan_id
        expect(billing_profile['activated_at']).to eq active_billing_profile.activated_at.iso8601
        expect(billing_profile['expires_at']).to eq active_billing_profile.expires_at.iso8601
      end

      it 'includes chargeable subscription' do
        is_expected.to eq 200

        billing_profile = body_hash['billing_profiles'][0]
        expect(billing_profile['chargeable']).to be_present
        expect(billing_profile['chargeable']['id']).to eq stripe_record_subscription.id
        expect(billing_profile['chargeable']['remote_id']).to eq stripe_record_subscription.remote_id
        expect(billing_profile['chargeable']['status']).to eq stripe_record_subscription.status
      end
    end

    context 'when contract does not exist' do
      let(:id) { 99_999 }

      it 'returns 404' do
        is_expected.to eq 404
      end
    end

    context 'when contract belongs to different user' do
      let!(:other_user) { create(:user, tenant_id: current_tenant.id, email: 'other@example.com', password: 'Password1234!') }
      let!(:other_contract) { create(:memberships__contract, tenant_id: current_tenant.id, user: other_user, status: 'active') }
      let(:id) { other_contract.id }

      it 'returns 404' do
        is_expected.to eq 404
      end
    end
  end

  describe 'GET /api/v1/internal/memberships/contracts/:id/polling' do
    include_context 'current user session is present'

    context 'when contract exists' do
      let(:id) { pending_contract.id }

      it 'returns contract for polling' do
        is_expected.to eq 200

        expect(body_hash['id']).to eq pending_contract.id
        expect(body_hash['status']).to eq pending_contract.status
        expect(body_hash['billing_profiles']).to be_present
      end

      it 'includes billing profiles without includes' do
        is_expected.to eq 200

        # pollingエンドポイントはincludes(:billing_profiles)を使わない
        expect(body_hash['billing_profiles']).to be_present
        expect(body_hash['billing_profiles'].size).to eq 1
      end
    end

    context 'when contract does not exist' do
      let(:id) { 99_999 }

      it 'returns 404' do
        is_expected.to eq 404
      end
    end
  end

  describe 'POST /api/v1/internal/memberships/contracts/:id/cancel' do
    include_context 'current user session is present'

    context 'when contract exists and has stripe subscription' do
      let(:id) { active_contract.id }

      before do
        # CancelSubscriptionServiceをモック
        allow_any_instance_of(UserStripe::CancelSubscriptionService).to receive(:execute).and_return(active_contract)
      end

      it 'cancels the subscription' do
        is_expected.to eq 200

        expect(body_hash['id']).to eq active_contract.id
        expect(body_hash['status']).to eq active_contract.status
      end

      it 'calls CancelSubscriptionService' do
        expect_any_instance_of(UserStripe::CancelSubscriptionService).to receive(:execute).with(contract: active_contract)
        is_expected.to eq 200
      end
    end

    context 'when contract has no stripe subscription' do
      let!(:contract_without_stripe) { create(:memberships__contract, tenant_id: current_tenant.id, user: current_user, status: 'active') }
      let(:id) { contract_without_stripe.id }

      before do
        create(:memberships__billing_profile, tenant_id: current_tenant.id, user: current_user, membership_plan:, membership_contract: contract_without_stripe, payment_type: 'credit_card',
         payment_provider: 'stripe', chargeable: nil, status: 'active',)
      end

      it 'returns 400 Bad Request with no_stripe_subscription error' do
        is_expected.to eq 400
        expect(body_hash[:error][:code]).to eq('no_stripe_subscription')
      end
    end

    context 'when contract has non-stripe chargeable' do
      let!(:contract_with_non_stripe) { create(:memberships__contract, tenant_id: current_tenant.id, user: current_user, status: 'active') }
      let(:id) { contract_with_non_stripe.id }

      before do
        create(:memberships__billing_profile, tenant_id: current_tenant.id, user: current_user, membership_plan:, membership_contract: contract_with_non_stripe, payment_type: 'credit_card',
         payment_provider: 'stripe', chargeable_type: 'SomeOtherModel', chargeable_id: 1, status: 'active',)
      end

      it 'returns 400 Bad Request with no_stripe_subscription error' do
        is_expected.to eq 400
        expect(body_hash[:error][:code]).to eq('no_stripe_subscription')
      end
    end

    context 'when contract does not exist' do
      let(:id) { 99_999 }

      it 'returns 404' do
        is_expected.to eq 404
      end
    end

    context 'when contract belongs to different user' do
      let!(:other_user) { create(:user, tenant_id: current_tenant.id, email: 'other@example.com', password: 'Password1234!') }
      let!(:other_contract) { create(:memberships__contract, tenant_id: current_tenant.id, user: other_user, status: 'active') }
      let(:id) { other_contract.id }

      it 'returns 404' do
        is_expected.to eq 404
      end
    end
  end

  describe 'when no session' do
    # rubocop:disable RSpec/RepeatedExampleGroupBody
    context 'GET /api/v1/internal/memberships/contracts' do
      it 'returns 401 Unauthorized' do
        is_expected.to eq 401
      end
    end

    context 'GET /api/v1/internal/memberships/contracts/:id' do
      let(:id) { active_contract.id }

      it 'returns 401 Unauthorized' do
        is_expected.to eq 401
      end
    end

    context 'GET /api/v1/internal/memberships/contracts/:id/polling' do
      let(:id) { active_contract.id }

      it 'returns 401 Unauthorized' do
        is_expected.to eq 401
      end
    end

    context 'POST /api/v1/internal/memberships/contracts/:id/cancel' do
      let(:id) { active_contract.id }

      it 'returns 401 Unauthorized' do
        is_expected.to eq 401
      end
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody
  end
end
