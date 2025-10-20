# typed: false
# frozen_string_literal: true

RSpec.describe '[ API::V1::Internal::MembershipController API ]' do
  # テスト用のメンバーシップグループ
  let!(:membership_group) { create(:membership_group, tenant_id: current_tenant.id, name: 'test_group', position: 1) }
  let!(:another_membership_group) { create(:membership_group, tenant_id: current_tenant.id, name: 'another_group', position: 2) }

  # テスト用のメンバーシップ
  let!(:active_membership_with_group) { create(:membership, tenant_id: current_tenant.id, membership_group:, name: 'active_membership_with_group', position: 1, tier: 1) }
  let!(:active_membership_without_group) { create(:membership, tenant_id: current_tenant.id, membership_group: nil, name: 'active_membership_without_group', position: 2, tier: 2) }
  let!(:inactive_membership) { create(:membership, tenant_id: current_tenant.id, membership_group: another_membership_group, name: 'inactive_membership', position: 3, tier: 3) }

  # メンバーシッププランとコンポーネント
  let!(:membership_plan_with_group) { create(:membership_plan, tenant_id: current_tenant.id, name: 'plan_with_group', amount: 1000, position: 1) }
  let!(:membership_plan_without_group) { create(:membership_plan, tenant_id: current_tenant.id, name: 'plan_without_group', amount: 2000, position: 1) }
  let!(:membership_plan_inactive) { create(:membership_plan, tenant_id: current_tenant.id, name: 'plan_inactive', amount: 3000, position: 1) }

  let!(:plan_component_with_group) { create(:membership_plan_component, membership_plan: membership_plan_with_group, membership: active_membership_with_group, tenant_id: current_tenant.id) }
  let!(:plan_component_without_group) {
    create(:membership_plan_component, membership_plan: membership_plan_without_group, membership: active_membership_without_group, tenant_id: current_tenant.id)
  }
  let!(:plan_component_inactive) { create(:membership_plan_component, membership_plan: membership_plan_inactive, membership: inactive_membership, tenant_id: current_tenant.id) }

  # メンバーシップ契約
  let!(:active_contract_with_group) { create(:membership_contract, tenant_id: current_tenant.id, user: current_user, status: 'active', expires_at: 1.year.from_now) }
  let!(:active_contract_without_group) { create(:membership_contract, tenant_id: current_tenant.id, user: current_user, status: 'active', expires_at: 1.year.from_now) }
  let!(:inactive_contract) { create(:membership_contract, tenant_id: current_tenant.id, user: current_user, status: 'pending', expires_at: 1.year.from_now) }

  # メンバーシップユーザー（アクティブ）
  let!(:active_membership_user_with_group) {
    create(:membership_user, tenant_id: current_tenant.id, user: current_user, membership: active_membership_with_group, membership_contract: active_contract_with_group, status: 'active')
  }
  let!(:active_membership_user_without_group) {
    create(:membership_user, tenant_id: current_tenant.id, user: current_user, membership: active_membership_without_group, membership_contract: active_contract_without_group, status: 'active')
  }

  # メンバーシップユーザー（非アクティブ）
  let!(:inactive_membership_user) {
    create(:membership_user, tenant_id: current_tenant.id, user: current_user, membership: inactive_membership, membership_contract: inactive_contract, status: 'pending')
  }

  before do
    # すべてのレコードを確実に作成
    active_contract_with_group
    active_contract_without_group
    inactive_contract
    plan_component_with_group
    plan_component_without_group
    plan_component_inactive
    active_membership_user_with_group
    active_membership_user_without_group
    inactive_membership_user
  end

  describe 'GET /api/v1/internal/memberships' do
    include_context 'current user session is present'

    it 'returns active memberships only' do
      is_expected.to eq 200

      expect(body_array.size).to eq 2

      # アクティブなメンバーシップのみが返されることを確認
      membership_ids = body_array.pluck('id')
      expect(membership_ids).to include(active_membership_with_group.id)
      expect(membership_ids).to include(active_membership_without_group.id)
      expect(membership_ids).not_to include(inactive_membership.id)
    end

    it 'returns memberships ordered by position' do
      is_expected.to eq 200

      expect(body_array.size).to eq 2

      # position順で返されることを確認
      expect(body_array[0]['id']).to eq active_membership_with_group.id
      expect(body_array[1]['id']).to eq active_membership_without_group.id
    end

    it 'includes membership group when present' do
      is_expected.to eq 200

      # グループを持つメンバーシップ
      membership_with_group = body_array.find { |membership| membership['id'] == active_membership_with_group.id }
      expect(membership_with_group['membership_group']).to be_present
      expect(membership_with_group['membership_group']['id']).to eq membership_group.id
      expect(membership_with_group['membership_group']['name']).to eq membership_group.name
      expect(membership_with_group['membership_group']['display_name']).to eq membership_group.display_name
      expect(membership_with_group['membership_group']['position']).to eq membership_group.position

      # グループを持たないメンバーシップ
      membership_without_group = body_array.find { |membership| membership['id'] == active_membership_without_group.id }
      expect(membership_without_group['membership_group']).to be_nil
    end


    it 'returns correct membership attributes' do
      is_expected.to eq 200

      membership = body_array.find { |membership| membership['id'] == active_membership_with_group.id }
      expect(membership['name']).to eq active_membership_with_group.name
      expect(membership['display_name']).to eq active_membership_with_group.display_name
      expect(membership['position']).to eq active_membership_with_group.position
      expect(membership['tier']).to eq active_membership_with_group.tier
    end

    context 'when user has no active memberships' do
      before do
        current_user.membership_users.update_all(status: 'pending')
      end

      it 'returns empty array' do
        is_expected.to eq 200

        expect(body_array.size).to eq 0
      end
    end

    context 'when user has no memberships' do
      before do
        current_user.membership_users.destroy_all
      end

      it 'returns empty array' do
        is_expected.to eq 200

        expect(body_array.size).to eq 0
      end
    end
  end

  describe 'when no session' do
    context 'GET /api/v1/internal/memberships' do
      it 'returns 401 Unauthorized' do
        is_expected.to eq 401
      end
    end
  end
end
