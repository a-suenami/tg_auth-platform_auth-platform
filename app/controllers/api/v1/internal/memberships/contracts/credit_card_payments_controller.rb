# typed: true
# frozen_string_literal: true

module API::V1::Internal::Memberships::Contracts
  class CreditCardPaymentsController < API::V1::Internal::Memberships::Contracts::ApplicationController
    def create
      @membership_plan = Memberships::Plan.find(params[:memberships_contracts][:memberships_plan_id])
      contract = Memberships::Contracts::CreateService.new.execute(user: current_user, membership_plan: @membership_plan, payment_method: 'credit_card')

      # TODO: もしクレカ会社が3DSに対応しておらず、即時決済完了になったら、3DSをスキップして、決済完了とする

      # ContractをBlueprintでシリアライズ
      render json: Memberships::ContractBlueprint.render(contract, view: :normal), status: :created
    end
  end
end
