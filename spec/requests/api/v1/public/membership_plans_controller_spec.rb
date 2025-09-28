# typed: false
# frozen_string_literal: true

RSpec.describe '[ API::V1::Public::MembershipPlansController API ]' do
  # 段階的メンバーシップグループ
  let!(:leveled_membership_group) { create(:memberships__group, tenant_id: current_tenant.id, name: 'leveled_membership_group', position: 1) }
  let!(:leveled_membership_platinum) { create(:membership, tenant_id: current_tenant.id, membership_group: leveled_membership_group, name: 'platinum', position: 1, tier: 1) }
  let!(:leveled_membership_premium) { create(:membership, tenant_id: current_tenant.id, membership_group: leveled_membership_group, name: 'premium', position: 2, tier: 2) }
  let!(:leveled_membership_basic) { create(:membership, tenant_id: current_tenant.id, membership_group: leveled_membership_group, name: 'basic', position: 3, tier: 3) }

  # 独立したメンバーシップ
  let!(:individual_membership_a) { create(:membership, tenant_id: current_tenant.id, name: 'member_a', position: 4, tier: 1) }
  let!(:individual_membership_b) { create(:membership, tenant_id: current_tenant.id, name: 'member_b', position: 5, tier: 1) }

  # メンバーシッププラン
  let!(:platinum_plan) {
    create(:memberships__plan, tenant_id: current_tenant.id, name: 'platinum_plan', amount: 5000, position: 1, recurring_interval_count: 1, recurring_interval_unit: 'month', trial_period_days: 7)
  }
  let!(:premium_plan) {
    create(:memberships__plan, tenant_id: current_tenant.id, name: 'premium_plan', amount: 3000, position: 2, recurring_interval_count: 1, recurring_interval_unit: 'month', trial_period_days: 0)
  }
  let!(:basic_plan) {
    create(:memberships__plan, tenant_id: current_tenant.id, name: 'basic_plan', amount: 1000, position: 3, recurring_interval_count: 1, recurring_interval_unit: 'month', trial_period_days: 0)
  }
  let!(:member_a_plan) {
    create(:memberships__plan, tenant_id: current_tenant.id, name: 'member_a_plan', amount: 2000, position: 4, recurring_interval_count: 1, recurring_interval_unit: 'month', trial_period_days: 0)
  }
  let!(:member_b_plan) {
    create(:memberships__plan, tenant_id: current_tenant.id, name: 'member_b_plan', amount: 2500, position: 5, recurring_interval_count: 1, recurring_interval_unit: 'month', trial_period_days: 0)
  }

  # プランコンポーネント
  let!(:platinum_plan_component) { create(:memberships__plan_component, membership_plan: platinum_plan, membership: leveled_membership_platinum, tenant_id: current_tenant.id) }
  let!(:premium_plan_component) { create(:memberships__plan_component, membership_plan: premium_plan, membership: leveled_membership_premium, tenant_id: current_tenant.id) }
  let!(:basic_plan_component) { create(:memberships__plan_component, membership_plan: basic_plan, membership: leveled_membership_basic, tenant_id: current_tenant.id) }
  let!(:member_a_plan_component) { create(:memberships__plan_component, membership_plan: member_a_plan, membership: individual_membership_a, tenant_id: current_tenant.id) }
  let!(:member_b_plan_component) { create(:memberships__plan_component, membership_plan: member_b_plan, membership: individual_membership_b, tenant_id: current_tenant.id) }

  # 支払い方法
  let!(:platinum_payment_method) { create(:memberships__plan_payment_method, membership_plan: platinum_plan, tenant_id: current_tenant.id, payment_type: 'credit_card', is_active: true) }
  let!(:premium_payment_method) { create(:memberships__plan_payment_method, membership_plan: premium_plan, tenant_id: current_tenant.id, payment_type: 'credit_card', is_active: true) }
  let!(:basic_payment_method) { create(:memberships__plan_payment_method, membership_plan: basic_plan, tenant_id: current_tenant.id, payment_type: 'credit_card', is_active: true) }
  let!(:member_a_payment_method) { create(:memberships__plan_payment_method, membership_plan: member_a_plan, tenant_id: current_tenant.id, payment_type: 'credit_card', is_active: true) }
  let!(:member_b_payment_method) { create(:memberships__plan_payment_method, membership_plan: member_b_plan, tenant_id: current_tenant.id, payment_type: 'credit_card', is_active: true) }

  # 非アクティブなプラン
  let!(:inactive_plan) { create(:memberships__plan, tenant_id: current_tenant.id, name: 'inactive_plan', amount: 1000, position: 6, is_active: false) }
  let!(:inactive_membership) { create(:membership, tenant_id: current_tenant.id, name: 'inactive_membership', position: 6, tier: 1) }
  let!(:inactive_plan_component) { create(:memberships__plan_component, membership_plan: inactive_plan, membership: inactive_membership, tenant_id: current_tenant.id) }
  let!(:inactive_payment_method) { create(:memberships__plan_payment_method, membership_plan: inactive_plan, tenant_id: current_tenant.id, payment_type: 'credit_card', is_active: false) }

  before do
    # すべてのレコードを確実に作成
    platinum_plan_component
    premium_plan_component
    basic_plan_component
    member_a_plan_component
    member_b_plan_component
    inactive_plan_component
    platinum_payment_method
    premium_payment_method
    basic_payment_method
    member_a_payment_method
    member_b_payment_method
    inactive_payment_method
  end

  describe 'GET /api/v1/public/membership_plans' do
    it 'returns all membership plans' do
      is_expected.to eq 200

      expect(body_array.size).to eq 5

      # プランの詳細確認
      platinum_plan_response = body_array.find { |plan| plan['id'] == platinum_plan.id }
      expect(platinum_plan_response).to be_present
      expect(platinum_plan_response['name']).to eq platinum_plan.name
      expect(platinum_plan_response['amount']).to eq platinum_plan.amount
      expect(platinum_plan_response['trial_period_days']).to eq platinum_plan.trial_period_days
      expect(platinum_plan_response['recurring_interval_unit']).to eq platinum_plan.recurring_interval_unit
      expect(platinum_plan_response['recurring_interval_count']).to eq platinum_plan.recurring_interval_count
    end

    it 'returns plans ordered by amount' do
      is_expected.to eq 200

      amounts = body_array.pluck('amount')
      expect(amounts).to eq [1000, 2000, 2500, 3000, 5000]
    end

    it 'includes payment methods in plans' do
      is_expected.to eq 200

      platinum_plan_response = body_array.find { |plan| plan['id'] == platinum_plan.id }
      expect(platinum_plan_response['plan_payment_methods']).to be_present
      expect(platinum_plan_response['plan_payment_methods'].size).to eq 1
      expect(platinum_plan_response['plan_payment_methods'][0]['payment_type']).to eq 'credit_card'
    end

    it 'includes plan components with memberships' do
      is_expected.to eq 200

      platinum_plan_response = body_array.find { |plan| plan['id'] == platinum_plan.id }

      expect(platinum_plan_response['memberships']).to be_present
      expect(platinum_plan_response['memberships'].size).to eq 1

      membership = platinum_plan_response['memberships'][0]
      expect(membership['id']).to eq leveled_membership_platinum.id
      expect(membership['name']).to eq leveled_membership_platinum.name
    end

    context 'when filtering by membership_id' do
      let(:params) { { membership_id: leveled_membership_platinum.id } }

      it 'returns only plans for the specified membership' do
        is_expected.to eq 200

        expect(body_array.size).to eq 1
        expect(body_array[0]['id']).to eq platinum_plan.id

        membership = body_array[0]['memberships'][0]
        expect(membership['id']).to eq leveled_membership_platinum.id
      end
    end

    context 'when filtering by payment_type' do
      let(:params) { { payment_type: 'credit_card' } }

      it 'returns only plans with credit card payment method' do
        is_expected.to eq 200

        expect(body_array.size).to eq 5

        body_array.each do |plan|
          expect(plan['plan_payment_methods']).to be_present
          expect(plan['plan_payment_methods'].any? { |pm| pm['payment_type'] == 'credit_card' }).to be true
        end
      end
    end

    context 'when filtering by both membership_id and payment_type' do
      let(:params) { { membership_id: leveled_membership_platinum.id, payment_type: 'credit_card' } }

      it 'returns plans matching both criteria' do
        is_expected.to eq 200

        expect(body_array.size).to eq 1
        expect(body_array[0]['id']).to eq platinum_plan.id

        membership = body_array[0]['memberships'][0]
        expect(membership['id']).to eq leveled_membership_platinum.id

        expect(body_array[0]['plan_payment_methods'].any? { |pm| pm['payment_type'] == 'credit_card' }).to be true
      end
    end

    context 'when filtering by non-existent membership_id' do
      let(:params) { { membership_id: 99_999 } }

      it 'returns empty array' do
        is_expected.to eq 200

        expect(body_array.size).to eq 0
      end
    end

    context 'when filtering by non-existent payment_type' do
      let(:params) { { payment_type: 'paypal' } }

      it 'returns empty array' do
        is_expected.to eq 200

        expect(body_array.size).to eq 0
      end
    end
  end

  describe 'GET /api/v1/public/membership_plans/:id' do
    context 'when plan exists' do
      let(:id) { platinum_plan.id }

      it 'returns specific membership plan' do
        is_expected.to eq 200

        expect(body_hash['id']).to eq platinum_plan.id
        expect(body_hash['name']).to eq platinum_plan.name
        expect(body_hash['amount']).to eq platinum_plan.amount
        expect(body_hash['trial_period_days']).to eq platinum_plan.trial_period_days
        expect(body_hash['recurring_interval_unit']).to eq platinum_plan.recurring_interval_unit
        expect(body_hash['recurring_interval_count']).to eq platinum_plan.recurring_interval_count
        expect(body_hash['is_active']).to eq platinum_plan.is_active
        expect(body_hash['position']).to eq platinum_plan.position
        expect(body_hash['recurrence']).to eq platinum_plan.recurrence
      end

      it 'includes payment methods' do
        is_expected.to eq 200

        expect(body_hash['plan_payment_methods']).to be_present
        expect(body_hash['plan_payment_methods'].size).to eq 1
        expect(body_hash['plan_payment_methods'][0]['payment_type']).to eq 'credit_card'
      end

      it 'includes plan components with memberships' do
        is_expected.to eq 200

        expect(body_hash['memberships']).to be_present
        expect(body_hash['memberships'].size).to eq 1

        membership = body_hash['memberships'][0]
        expect(membership['id']).to eq leveled_membership_platinum.id
        expect(membership['name']).to eq leveled_membership_platinum.name
        expect(membership['display_name']).to eq leveled_membership_platinum.display_name
        expect(membership['tier']).to eq leveled_membership_platinum.tier
      end
    end

    context 'when plan does not exist' do
      let(:id) { 99_999 }

      it 'returns 404' do
        is_expected.to eq 404
      end
    end

    context 'when plan belongs to different tenant' do
      let(:other_tenant) { create(:tenant, id: 'other', name: 'other_tenant') }
      let(:other_plan) { create(:memberships__plan, tenant_id: other_tenant.id, name: 'other_plan', amount: 1000) }
      let(:id) { other_plan.id }

      it 'returns 404' do
        is_expected.to eq 404
      end
    end
  end
end
