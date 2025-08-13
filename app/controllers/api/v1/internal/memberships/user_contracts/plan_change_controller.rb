# typed: true
# frozen_string_literal: true

module API::V1::Internal::Memberships::UserContracts
  class PlanChangeController < API::V1::Internal::Memberships::UserContracts::ApplicationController

    before_action :set_user_contract

    def preview
      # プラン変更のプレビュー情報を返す
      new_membership_plan = Memberships::Plan.find(plan_change_params[:memberships_plan_id])

      # 変更可能かチェック
      service = Memberships::PlanChangeService.new
      can_change = service.send(:validate_plan_change, user_contract: @user_contract, new_membership_plan:)

      render json: {
        can_change:,
        current_plan: {
          id: @user_contract.current_billing_profile&.membership_plan&.id,
          name: @user_contract.current_billing_profile&.membership_plan&.name,
          amount: @user_contract.current_billing_profile&.membership_plan&.amount,
          validity_period: @user_contract.current_billing_profile&.membership_plan&.validity_period,
        },
        new_plan: {
          id: new_membership_plan.id,
          name: new_membership_plan.name,
          amount: new_membership_plan.amount,
          validity_period: new_membership_plan.validity_period,
        },
      }
    end

    def create
      new_membership_plan = Memberships::Plan.find(plan_change_params[:memberships_plan_id])

      service = Memberships::PlanChangeService.new
      user_contract = service.execute(user_contract: @user_contract, new_membership_plan:)

      render json: Memberships::UserContractBlueprint.render(user_contract)
    end

    private

    def set_user_contract
      @user_contract = current_user.membership_user_contracts.find(params[:id])
    end

    def plan_change_params
      params.require(:plan_change).permit(:memberships_plan_id)
    end
  end
end
