# typed: strict
# frozen_string_literal: true

module API::V1::Internal::Membership::Contracts
  class SetupIntentsController < API::V1::Internal::Membership::Contracts::ApplicationController
    sig { void }
    def create
      tenant_stripe_account = T.must(Tenant.current!).tenant_stripe_account
      result = StripeRecord::SetupIntent.api_create_off_session_setup_intent(tenant_stripe_account:, user: current_user)

      if result.is_a?(Mangrove::Result::Err)
        render json: { error: { code: 'stripe_error', message: result.err_inner.message } }, status: :bad_request
        return
      end

      setup_intent = T.must(result.ok_inner)
      render json: StripeRecord::SetupIntentBlueprint.render(setup_intent, view: :normal), status: :created
    end
  end
end
