# typed: true
# frozen_string_literal: true

module API::V1::Public
  class MembershipPlansController < API::ApplicationController
    def index
      plans = Membership::Plan.includes(:plan_payment_methods, :plan_components, plan_components: :membership)
                              .joins(:plan_components)
                              .active
                              .distinct

      # メンバーシップIDで絞り込み
      if params[:membership_id].present?
        plans = plans.joins(plan_components: :membership)
                    .where(membership_plan_components: { membership_id: params[:membership_id] })
      end

      # 支払い方法で絞り込み
      if params[:payment_type].present?
        plans = plans.joins(:plan_payment_methods)
                    .where(membership_plan_payment_methods: { payment_type: params[:payment_type] })
      end

      plans = plans.order(:amount)

      render_blueprint_collection(MembershipPlanBlueprint, plans, view: :normal)
    end

    def show
      plan = Membership::Plan.includes(:plan_payment_methods, :plan_components, plan_components: :membership)
                             .active
                             .find(params[:id])

      render_blueprint(MembershipPlanBlueprint, plan, view: :normal)
    end
  end
end
