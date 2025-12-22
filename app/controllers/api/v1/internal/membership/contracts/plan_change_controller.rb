# typed: true
# frozen_string_literal: true

module API::V1::Internal::Membership::Contracts
  class PlanChangeController < API::V1::Internal::Membership::Contracts::ApplicationController

    before_action :set_contract

    # TODO: 料金の確認
    def preview
    end

    def create
      new_membership_plan = Membership::Plan.find(plan_change_params[:membership_plan_id])

      service = UserStripe::ChangePlanService.new
      contract = service.execute(contract: @contract, new_membership_plan:)

      render json: Membership::ContractBlueprint.render(contract)
    end

    private

    def set_contract
      @contract = current_user.membership_contracts.find(params[:id])
    end

    def plan_change_params
      params.require(:plan_change).permit(:membership_plan_id)
    end
  end
end
