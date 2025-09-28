# typed: true
# frozen_string_literal: true

module API::V1::Internal
  class MembershipsController < API::V1::Internal::ApplicationController
    def index
      active_memberships = current_user.memberships
                                       .joins(:membership_users)
                                       .where(memberships__users: { status: 'active' })
                                       .includes(:membership_group)
                                       .order(:position)

      render_blueprint_collection(MembershipBlueprint, active_memberships, view: :normal)
    end
  end
end
