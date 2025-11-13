# typed: true
# frozen_string_literal: true

module API::V1::Public
  class MembershipGroupsController < API::ApplicationController
    def index
      groups = Membership::Group.includes(:memberships, memberships: :membership_group)
                                .order(:position)

      render_blueprint_collection(MembershipGroupBlueprint, groups, view: :normal)
    end

    def show
      group = Membership::Group.includes(:memberships, memberships: :membership_group)
                               .find(params[:id])

      render_blueprint(MembershipGroupBlueprint, group, view: :normal)
    end
  end
end
