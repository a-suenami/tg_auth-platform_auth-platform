# typed: true
# frozen_string_literal: true

module API::V1::Public
  class MembershipsController < API::ApplicationController
    def index
      memberships = Membership.includes(:membership_group, membership_plans: :plan_payment_methods)
                             .order(:position)

      # メンバーシップIDで絞り込み
      if params[:membership_id].present?
        memberships = memberships.where(id: params[:membership_id])
      end

      # 支払い方法で絞り込み
      if params[:payment_type].present?
        memberships = memberships.joins(membership_plans: :plan_payment_methods)
                                .where(memberships__plan_payment_methods: { payment_type: params[:payment_type] })
                                .distinct
      end

      render_blueprint_collection(MembershipBlueprint, memberships, view: :normal)
    end

    def show
      membership = Membership.includes(:membership_group, membership_plans: :plan_payment_methods)
                           .find(params[:id])

      render_blueprint(MembershipBlueprint, membership, view: :normal)
    end

    def by_group
      group = Memberships::Group.find(params[:group_id])
      memberships = group.memberships.includes(:membership_group, membership_plans: :plan_payment_methods)
                        .order(:position)

      render_blueprint_collection(MembershipBlueprint, memberships, view: :normal)
    end
  end
end
