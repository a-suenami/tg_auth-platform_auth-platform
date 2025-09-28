# typed: false
# frozen_string_literal: true

RSpec.describe '[ API::V1::Public::MembershipGroupsController API ]' do
  # 段階的メンバーシップグループ
  let!(:leveled_membership_group) { create(:memberships__group, tenant_id: current_tenant.id, name: 'leveled_membership_group', position: 1) }
  let!(:leveled_membership_platinum) { create(:membership, tenant_id: current_tenant.id, membership_group: leveled_membership_group, name: 'platinum', position: 1, tier: 1) }
  let!(:leveled_membership_premium) { create(:membership, tenant_id: current_tenant.id, membership_group: leveled_membership_group, name: 'premium', position: 2, tier: 2) }
  let!(:leveled_membership_basic) { create(:membership, tenant_id: current_tenant.id, membership_group: leveled_membership_group, name: 'basic', position: 3, tier: 3) }

  # 独立したメンバーシップグループ
  let!(:individual_membership_group) { create(:memberships__group, tenant_id: current_tenant.id, name: 'individual_membership_group', position: 2) }
  let!(:individual_membership_a) { create(:membership, tenant_id: current_tenant.id, membership_group: individual_membership_group, name: 'member_a', position: 1, tier: 1) }
  let!(:individual_membership_b) { create(:membership, tenant_id: current_tenant.id, membership_group: individual_membership_group, name: 'member_b', position: 2, tier: 1) }

  # グループなしのメンバーシップ
  let!(:standalone_membership) { create(:membership, tenant_id: current_tenant.id, membership_group: nil, name: 'standalone', position: 4, tier: 1) }

  before do
    # メンバーシッププランとコンポーネントを作成
    create_membership_plans_for_group(leveled_membership_group, [leveled_membership_platinum, leveled_membership_premium, leveled_membership_basic])
    create_membership_plans_for_group(individual_membership_group, [individual_membership_a, individual_membership_b])
    create_membership_plan_for_membership(standalone_membership)
  end

  def create_membership_plans_for_group(_group, memberships)
    memberships.each do |membership|
      plan = create(:memberships__plan, tenant_id: current_tenant.id, name: "#{membership.name}_plan", amount: 1000 + (membership.position * 1000))
      create(:memberships__plan_component, membership_plan: plan, membership:, tenant_id: current_tenant.id)
      create(:memberships__plan_payment_method, membership_plan: plan, tenant_id: current_tenant.id, payment_type: 'credit_card')
    end
  end

  def create_membership_plan_for_membership(membership)
    plan = create(:memberships__plan, tenant_id: current_tenant.id, name: "#{membership.name}_plan", amount: 2000)
    create(:memberships__plan_component, membership_plan: plan, membership:, tenant_id: current_tenant.id)
    create(:memberships__plan_payment_method, membership_plan: plan, tenant_id: current_tenant.id, payment_type: 'credit_card')
  end

  describe 'GET /api/v1/public/membership_groups' do
    it 'returns all membership groups' do
      is_expected.to eq 200

      expect(body_array.size).to eq 2

      # 最初のグループ（leveled_membership_group）
      first_group = body_array.find { |group| group['id'] == leveled_membership_group.id }
      expect(first_group).to be_present
      expect(first_group['name']).to eq leveled_membership_group.name
      expect(first_group['position']).to eq leveled_membership_group.position
      expect(first_group['memberships'].size).to eq 3

      # メンバーシップの順序確認
      membership_names = first_group['memberships'].pluck('name')
      expect(membership_names).to eq ['platinum', 'premium', 'basic']

      # 2番目のグループ（individual_membership_group）
      second_group = body_array.find { |group| group['id'] == individual_membership_group.id }
      expect(second_group).to be_present
      expect(second_group['name']).to eq individual_membership_group.name
      expect(second_group['position']).to eq individual_membership_group.position
      expect(second_group['memberships'].size).to eq 2
    end

    it 'returns groups ordered by position' do
      is_expected.to eq 200

      expect(body_array[0]['position']).to eq 1
      expect(body_array[1]['position']).to eq 2
    end

    it 'includes membership details in groups' do
      is_expected.to eq 200

      first_group = body_array.find { |group| group['id'] == leveled_membership_group.id }
      membership = first_group['memberships'].find { |m| m['name'] == 'platinum' }

      expect(membership['id']).to eq leveled_membership_platinum.id
      expect(membership['name']).to eq leveled_membership_platinum.name
      expect(membership['display_name']).to eq leveled_membership_platinum.display_name
      expect(membership['position']).to eq leveled_membership_platinum.position
      expect(membership['tier']).to eq leveled_membership_platinum.tier
    end
  end

  describe 'GET /api/v1/public/membership_groups/:id' do
    context 'when group exists' do
      let(:id) { leveled_membership_group.id }

      it 'returns specific membership group' do
        is_expected.to eq 200

        expect(body_hash['id']).to eq leveled_membership_group.id
        expect(body_hash['name']).to eq leveled_membership_group.name
        expect(body_hash['position']).to eq leveled_membership_group.position
        expect(body_hash['memberships'].size).to eq 3

        # メンバーシップの詳細確認
        platinum_membership = body_hash['memberships'].find { |m| m['name'] == 'platinum' }
        expect(platinum_membership['id']).to eq leveled_membership_platinum.id
        expect(platinum_membership['display_name']).to eq leveled_membership_platinum.display_name
        expect(platinum_membership['tier']).to eq leveled_membership_platinum.tier
      end

      it 'includes all memberships in the group' do
        is_expected.to eq 200

        membership_names = body_hash['memberships'].pluck('name')
        expect(membership_names).to contain_exactly('platinum', 'premium', 'basic')
      end
    end

    context 'when group does not exist' do
      let(:id) { 99_999 }

      it 'returns 404' do
        is_expected.to eq 404
      end
    end

    context 'when group belongs to different tenant' do
      let(:other_tenant) { create(:tenant, id: 'other', name: 'other_tenant') }
      let(:other_group) { create(:memberships__group, tenant_id: other_tenant.id, name: 'other_group') }
      let(:id) { other_group.id }

      it 'returns 404' do
        is_expected.to eq 404
      end
    end
  end
end
