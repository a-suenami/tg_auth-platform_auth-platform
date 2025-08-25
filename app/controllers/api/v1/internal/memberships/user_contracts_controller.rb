# typed: true
# frozen_string_literal: true

module API::V1::Internal::Memberships
  class UserContractsController < API::V1::Internal::Memberships::ApplicationController
    def index
      user_contracts = current_user.membership_user_contracts
                                   .includes(:billing_profiles)
                                   .order(created_at: :desc)

      render_blueprint_collection(Memberships::UserContractBlueprint, user_contracts, view: :normal)
    end

    def show
      user_contract = current_user.membership_user_contracts
                                 .includes(:billing_profiles)
                                 .find(params[:id])

      render_blueprint(Memberships::UserContractBlueprint, user_contract, view: :normal)
    end

    def polling
      user_contract = current_user.membership_user_contracts.find(params[:id])

      render_blueprint(Memberships::UserContractBlueprint, user_contract, view: :normal)
    end

    # メンバーシップの自動更新のキャンセル（次回から)
    def cancel
      user_contract = current_user.membership_user_contracts.find(params[:id])

      # 現在のBillingProfileを取得
      current_billing_profile = user_contract.current_billing_profile

      raise Exceptions::Payment::NoStripeSubscription if current_billing_profile&.chargeable_type == 'StripeRecord::Subscription'

      user_contract = UserStripe::CancelSubscriptionService.new.execute(user_contract:)

      render_blueprint(Memberships::UserContractBlueprint, user_contract, view: :normal)
    end
  end
end
