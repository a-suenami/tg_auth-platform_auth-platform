# typed: true
# frozen_string_literal: true

module API::V1::Internal::Memberships
  class ContractsController < API::V1::Internal::Memberships::ApplicationController
    def index
      contracts = current_user.membership_contracts
                                   .includes(:transactions)
                                   .order(created_at: :desc)

      render_blueprint_collection(Memberships::ContractBlueprint, contracts, view: :normal)
    end

    def show
      contract = current_user.membership_contracts
                                 .includes(:transactions)
                                 .find(params[:id])

      render_blueprint(Memberships::ContractBlueprint, contract, view: :normal)
    end

    def polling
      contract = current_user.membership_contracts.find(params[:id])

      render_blueprint(Memberships::ContractBlueprint, contract, view: :normal)
    end

    # メンバーシップの自動更新のキャンセル（次回から)
    def cancel
      contract = current_user.membership_contracts.find(params[:id])

      # 現在のTransactionを取得
      current_transaction = contract.current_transaction

      raise Exceptions::Payment::NoStripeSubscription if current_transaction&.chargeable_type != 'StripeRecord::Subscription'

      contract = UserStripe::CancelSubscriptionService.new.execute(contract:)

      render_blueprint(Memberships::ContractBlueprint, contract, view: :normal)
    end
  end
end
