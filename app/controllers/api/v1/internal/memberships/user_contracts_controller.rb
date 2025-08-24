# typed: true
# frozen_string_literal: true

module API::V1::Internal::Memberships
  class UserContractsController < API::V1::Internal::Memberships::ApplicationController
    # メンバーシップの自動更新のキャンセル（次回から)
    def cancel
      user_contract = current_user.membership_user_contracts.find(params[:id])

      # 現在のBillingProfileを取得
      current_billing_profile = user_contract.current_billing_profile

      raise Exceptions::Payment::NoStripeSubscription if current_billing_profile&.chargeable_type == 'StripeRecord::Subscription'

      user_contract = UserStripe::CancelSubscriptionService.new.execute(user_contract:)

      render json: Memberships::UserContractBlueprint.render(user_contract), status: :updated
    end
  end
end
