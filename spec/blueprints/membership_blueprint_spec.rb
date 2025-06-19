# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MembershipBlueprint do
  let(:tenant) { create(:tenant) }
  let(:membership) { create(:membership, tenant:) }
  let(:membership_group) { create(:memberships_group, tenant:) }
  let(:membership_plan) { create(:memberships_plan, tenant:) }
  let(:plan_payment_method) { create(:memberships_plan_payment_method, membership_plan:) }

  before do
    # 関連データを作成
    create(:memberships_group_assignment, membership:, membership_group:)
    create(:memberships_plan_component, membership:, membership_plan:)
    plan_payment_method
  end

  describe '#render_as_hash' do
    subject { MembershipBlueprint.render_as_hash(membership) }

    it 'returns membership data with basic fields' do
      expect(subject).to include(
        'id' => membership.id,
        'name' => membership.name,
        'display_name' => membership.display_name,
        'position' => membership.position,
        'tier' => membership.tier,
      )
    end

    it 'includes groups association' do
      expect(subject['groups']).to be_an(Array)
      expect(subject['groups'].first).to include(
        'id' => membership_group.id,
        'name' => membership_group.name,
        'display_name' => membership_group.display_name,
      )
    end

    it 'includes membership_plans association' do
      expect(subject['membership_plans']).to be_an(Array)
      expect(subject['membership_plans'].first).to include(
        'id' => membership_plan.id,
        'billing_cycle' => membership_plan.billing_cycle,
        'validity_period' => membership_plan.validity_period,
        'amount' => membership_plan.amount,
      )
    end
  end

  describe '#render_as_hash with includes' do
    subject { MembershipBlueprint.render_as_hash(membership, include: [:groups, :membership_plans]) }

    it 'includes specified associations' do
      expect(subject).to have_key('groups')
      expect(subject).to have_key('membership_plans')
    end
  end

  describe '#render_as_hash for collection' do
    subject { MembershipBlueprint.render_as_hash(memberships) }

    let(:memberships) { [membership, create(:membership, tenant:)] }


    it 'returns array of membership data' do
      expect(subject).to be_an(Array)
      expect(subject.length).to eq(2)
      expect(subject.first).to include('id' => membership.id)
    end
  end
end
