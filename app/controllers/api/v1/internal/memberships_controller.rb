# typed: true
# frozen_string_literal: true

module API::V1::Internal
  class MembershipsController < API::V1::Internal::ApplicationController
    def index
      active_memberships = current_user.memberships
                                       .joins(:membership_users)
                                       .where(membership_users: { status: 'active' })
                                       .includes(:membership_group)
                                       .order(:position)

      render_blueprint_collection(MembershipBlueprint, active_memberships, view: :personal)
    end
  end
end
