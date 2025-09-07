# typed: true
# frozen_string_literal: true

module API::V1::Internal::Memberships::Contracts
  class PlanChangeController < API::V1::Internal::Memberships::Contracts::ApplicationController

    before_action :set_contract

    # TODO: 料金の確認
    def preview
      # プラン変更のプレビュー情報を返す
      new_membership_plan = Memberships::Plan.find(plan_change_params[:memberships_plan_id])

      # 変更可能かチェック
      service = UserStripe::ChangePlanService.new
      can_change = service.send(:validate_plan_change, contract: @contract, new_membership_plan:)

      render json: {
        can_change:,
        current_plan: {
          id: @contract.current_billing_profile&.membership_plan&.id,
          name: @contract.current_billing_profile&.membership_plan&.name,
          amount: @contract.current_billing_profile&.membership_plan&.amount,
          validity_period: @contract.current_billing_profile&.membership_plan&.validity_period,
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

      service = UserStripe::ChangePlanService.new
      contract = service.execute(contract: @contract, new_membership_plan:)

      render json: Memberships::ContractBlueprint.render(contract)
    end

    private

    def set_contract
      @contract = current_user.membership_contracts.find(params[:id])
    end

    def plan_change_params
      params.require(:plan_change).permit(:memberships_plan_id)
    end
  end
end
