# typed: false
# frozen_string_literal: true

RSpec.describe '[ API::V1::Public::MembershipsController API ]' do
  # パターン別メンバーシッププラン
  # 1. 段階的プラン
  # - メンバーシップに上下関係があり、上位のものが下位の完全な上位互換の権限を持つタイプ
  # - 同じグループに囲われたメンバーシップは同時に契約不可(上位互換のため同時契約するメリットはなし)
  # - membershipに同じmembership_groupを紐づける
  let!(:membership_basic) { create(:membership, tenant_id: current_tenant.id, membership_group: membership_group_for_level, position: 1) }
  let!(:membership_standard) { create(:membership, tenant_id: current_tenant.id, membership_group: membership_group_for_level, position: 2) }
  let!(:membership_premium) { create(:membership, tenant_id: current_tenant.id, membership_group: membership_group_for_level, position: 3) }
  let!(:membership_group_for_level) { create(:memberships__group, tenant_id: current_tenant.id) }
  let!(:membership_plan_basic) { create(:memberships__plan, tenant_id: current_tenant.id, position: 1) }
  let!(:membership_plan_standard) { create(:memberships__plan, tenant_id: current_tenant.id, position: 1) }
  let!(:membership_plan_premium) { create(:memberships__plan, tenant_id: current_tenant.id, position: 1) }
  let!(:membership_plan_component_basic) { create(:memberships__plan_component, membership_plan: membership_plan_basic, membership: membership_basic, tenant_id: current_tenant.id) }
  let!(:membership_plan_component_standard) { create(:memberships__plan_component, membership_plan: membership_plan_standard, membership: membership_standard, tenant_id: current_tenant.id) }
  let!(:membership_plan_component_premium) { create(:memberships__plan_component, membership_plan: membership_plan_premium, membership: membership_premium, tenant_id: current_tenant.id) }
  let!(:membership_plan_payment_method_basic) { create(:memberships__plan_payment_method, membership_plan: membership_plan_basic, tenant_id: current_tenant.id) }
  let!(:membership_plan_payment_method_standard) {
    create(:memberships__plan_payment_method, membership_plan: membership_plan_standard, tenant_id: current_tenant.id)
  }
  let!(:membership_plan_payment_method_premium) {
    create(:memberships__plan_payment_method, membership_plan: membership_plan_premium, tenant_id: current_tenant.id)
  }
  # 2. 個別メンバーシッププラン
  # - 独立したプラン 各々同時契約可能
  # - ex) アイドルの各メンバーごとのメンバーシップ
  let!(:membership_a) { create(:membership, tenant_id: current_tenant.id, position: 4) }
  let!(:membership_b) { create(:membership, tenant_id: current_tenant.id, position: 5) }
  let!(:membership_c) { create(:membership, tenant_id: current_tenant.id, position: 6) }
  let!(:membership_plan_a) { create(:memberships__plan, tenant_id: current_tenant.id, position: 1) }
  let!(:membership_plan_b) { create(:memberships__plan, tenant_id: current_tenant.id, position: 1) }
  let!(:membership_plan_c) { create(:memberships__plan, tenant_id: current_tenant.id, position: 1) }
  let!(:membership_plan_component_a) { create(:memberships__plan_component, membership_plan: membership_plan_a, membership: membership_a, tenant_id: current_tenant.id) }
  let!(:membership_plan_component_b) { create(:memberships__plan_component, membership_plan: membership_plan_b, membership: membership_b, tenant_id: current_tenant.id) }
  let!(:membership_plan_component_c) { create(:memberships__plan_component, membership_plan: membership_plan_c, membership: membership_c, tenant_id: current_tenant.id) }
  let!(:membership_plan_payment_method_a) { create(:memberships__plan_payment_method, membership_plan: membership_plan_a, tenant_id: current_tenant.id) }
  let!(:membership_plan_payment_method_b) { create(:memberships__plan_payment_method, membership_plan: membership_plan_b, tenant_id: current_tenant.id) }
  let!(:membership_plan_payment_method_c) { create(:memberships__plan_payment_method, membership_plan: membership_plan_c, tenant_id: current_tenant.id) }

  # 3. バンドルプラン
  # - 複数のメンバーシップを組み合わせたプラン
  # - ex) アイドルのメンバーごとのメンバーシップを組み合わせたプラン
  let!(:membership_plan_bundle) { create(:memberships__plan, tenant_id: current_tenant.id, position: 7) }
  let!(:membership_plan_component_bundle_a) { create(:memberships__plan_component, membership_plan: membership_plan_bundle, membership: membership_a, tenant_id: current_tenant.id) }
  let!(:membership_plan_component_bundle_b) { create(:memberships__plan_component, membership_plan: membership_plan_bundle, membership: membership_b, tenant_id: current_tenant.id) }
  let!(:membership_plan_component_bundle_c) { create(:memberships__plan_component, membership_plan: membership_plan_bundle, membership: membership_c, tenant_id: current_tenant.id) }
  let!(:membership_plan_payment_method_bundle) { create(:memberships__plan_payment_method, membership_plan: membership_plan_bundle, tenant_id: current_tenant.id) }

  before do
    membership_plan_component_basic
    membership_plan_component_standard
    membership_plan_component_premium
    membership_plan_payment_method_basic
    membership_plan_payment_method_standard
    membership_plan_payment_method_premium
    membership_plan_component_a
    membership_plan_component_b
    membership_plan_component_c
    membership_plan_payment_method_a
    membership_plan_payment_method_b
    membership_plan_payment_method_c
    membership_plan_payment_method_bundle
    membership_plan_component_bundle_a
    membership_plan_component_bundle_b
    membership_plan_component_bundle_c
  end

  describe 'GET /api/v1/public/memberships' do
    it 'returns all memberships' do
      is_expected.to eq 200

      # body_array example
      expect(body_array.size).to eq 6
      expect(body_array[0]['id']).to eq membership_basic.id
      expect(body_array[0]['display_name']).to eq membership_basic.display_name
      expect(body_array[0]['membership_group']['id']).to eq membership_basic.membership_group.id
      expect(body_array[0]['name']).to eq membership_basic.name
      expect(body_array[0]['position']).to eq membership_basic.position
      expect(body_array[0]['tier']).to eq membership_basic.tier
      expect(body_array[0]['membership_plans'].count).to eq 1
      expect(body_array[0]['membership_plans'][0]['id']).to eq membership_plan_basic.id
      expect(body_array[0]['membership_plans'][0]['amount']).to eq membership_plan_basic.amount
      expect(body_array[0]['membership_plans'][0]['disabled_at']).to eq membership_plan_basic.disabled_at
      expect(body_array[0]['membership_plans'][0]['enabled_at']).to eq membership_plan_basic.enabled_at.iso8601
      expect(body_array[0]['membership_plans'][0]['is_active']).to eq membership_plan_basic.is_active
      expect(body_array[0]['membership_plans'][0]['name']).to eq membership_plan_basic.name
      expect(body_array[0]['membership_plans'][0]['position']).to eq membership_plan_basic.position
      expect(body_array[0]['membership_plans'][0]['recurrence']).to eq membership_plan_basic.recurrence
      expect(body_array[0]['membership_plans'][0]['trial_period_days']).to eq membership_plan_basic.trial_period_days
      expect(body_array[0]['membership_plans'][0]['validity_period']).to eq membership_plan_basic.validity_period
    end
  end

  describe 'GET /api/v1/public/memberships/:membership_id' do

    context 'when membership_id is present' do
      let(:membership_id) { membership_basic.id }

      it 'returns a specific membership' do
        is_expected.to eq 200

        # body example
        expect(body_hash['id']).to eq membership_basic.id
        expect(body_hash['display_name']).to eq membership_basic.display_name
        expect(body_hash['membership_group']['id']).to eq membership_basic.membership_group.id
        expect(body_hash['name']).to eq membership_basic.name
        expect(body_hash['position']).to eq membership_basic.position
        expect(body_hash['tier']).to eq membership_basic.tier
        expect(body_hash['membership_plans'].count).to eq 1
        expect(body_hash['membership_plans'][0]['id']).to eq membership_plan_basic.id
        expect(body_hash['membership_plans'][0]['amount']).to eq membership_plan_basic.amount
        expect(body_hash['membership_plans'][0]['disabled_at']).to be_nil
        expect(body_hash['membership_plans'][0]['enabled_at']).to eq membership_plan_basic.enabled_at.iso8601
        expect(body_hash['membership_plans'][0]['is_active']).to eq membership_plan_basic.is_active
        expect(body_hash['membership_plans'][0]['name']).to eq membership_plan_basic.name
        expect(body_hash['membership_plans'][0]['position']).to eq membership_plan_basic.position
        expect(body_hash['membership_plans'][0]['recurrence']).to eq membership_plan_basic.recurrence
        expect(body_hash['membership_plans'][0]['trial_period_days']).to eq membership_plan_basic.trial_period_days
        expect(body_hash['membership_plans'][0]['validity_period']).to eq membership_plan_basic.validity_period
      end
    end

    context 'when membership_id is not present' do
      let(:membership_id) { 'nil' }

      it 'returns 404 for non-existent membership' do

        is_expected.to eq 404
      end
    end
  end
end
