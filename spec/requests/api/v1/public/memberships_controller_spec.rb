# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API::V1::Public::MembershipsController' do
  let(:tenant) { create(:tenant) }
  let(:membership) { create(:membership, tenant:) }
  let(:membership_group) { create(:memberships_group, tenant:) }
  let(:membership_plan) { create(:memberships_plan, tenant:) }

  before do
    # 関連データを作成
    create(:memberships_group_assignment, membership:, membership_group:)
    create(:memberships_plan_component, membership:, membership_plan:)
    create(:memberships_plan_payment_method, membership_plan:)
  end

  describe 'GET /api/v1/public/memberships' do
    it 'returns all memberships' do
      get '/api/v1/public/memberships'

      expect(response).to have_http_status(:ok)
      json = response.parsed_body

      expect(json).to be_an(Array)
      expect(json.first).to include(
        'id' => membership.id,
        'name' => membership.name,
        'display_name' => membership.display_name,
      )
    end
  end

  describe 'GET /api/v1/public/memberships/:id' do
    it 'returns a specific membership' do
      get "/api/v1/public/memberships/#{membership.id}"

      expect(response).to have_http_status(:ok)
      json = response.parsed_body

      expect(json).to include(
        'id' => membership.id,
        'name' => membership.name,
        'display_name' => membership.display_name,
      )
      expect(json['groups']).to be_an(Array)
      expect(json['membership_plans']).to be_an(Array)
    end

    it 'returns 404 for non-existent membership' do
      get '/api/v1/public/memberships/non-existent-id'

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /api/v1/public/memberships/by_group' do
    it 'returns memberships by group' do
      get "/api/v1/public/memberships/by_group?group_id=#{membership_group.id}"

      expect(response).to have_http_status(:ok)
      json = response.parsed_body

      expect(json).to be_an(Array)
      expect(json.first).to include(
        'id' => membership.id,
        'name' => membership.name,
        'display_name' => membership.display_name,
      )
    end

    it 'returns 404 for non-existent group' do
      get '/api/v1/public/memberships/by_group?group_id=non-existent-id'

      expect(response).to have_http_status(:not_found)
    end
  end
end
