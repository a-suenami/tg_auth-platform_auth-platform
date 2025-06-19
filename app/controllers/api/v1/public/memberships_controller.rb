# typed: true
# frozen_string_literal: true

module API::V1::Public
  class MembershipsController < API::ApplicationController
    def index
      memberships = Membership.includes(:groups, membership_plans: :plan_payment_methods)
                             .order(:position)

      render_blueprint_collection(MembershipBlueprint, memberships, include: [:groups, :membership_plans])
    end

    def show
      membership = Membership.includes(:groups, membership_plans: :plan_payment_methods)
                           .find(params[:id])

      render_blueprint(MembershipBlueprint, membership, include: [:groups, :membership_plans])
    end

    def by_group
      group = Memberships::Group.find(params[:group_id])
      memberships = group.memberships.includes(:groups, membership_plans: :plan_payment_methods)
                        .order(:position)

      render_blueprint_collection(MembershipBlueprint, memberships, include: [:groups, :membership_plans])
    end
  end
end
