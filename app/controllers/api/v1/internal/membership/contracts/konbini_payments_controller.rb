# typed: true
# frozen_string_literal: true

module API::V1::Internal::Membership::Contracts
  class KonbiniPaymentsController < API::V1::Internal::Membership::Contracts::ApplicationController
    def create
      @membership_plan = Membership::Plan.find(memberships_contracts_params[:membership_plan_id])
      store = memberships_contracts_params[:store]

      contract = Membership::Contracts::CreateService.new.execute(
        user: current_user,
        membership_plan: @membership_plan,
        payment_method: 'convenience',
        store: store,
      )

      # ContractをBlueprintでシリアライズ
      render json: Membership::ContractBlueprint.render(contract, view: :detailed), status: :created
    end

    private

    def memberships_contracts_params
      params.require(:memberships_contracts).permit(:membership_plan_id, :store)
    end
  end
end
