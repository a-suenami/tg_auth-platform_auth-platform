# typed: false

module UserStripe
  class CompleteSetupIntentContractService < UserStripe::BaseService
    def initialize(event:)
      @event = event
    end

    def execute
      setup_intent = @event.data.object
      stripe_record_setup_intent = StripeRecord::SetupIntent.find_by(remote_id: setup_intent.id)
      return unless stripe_record_setup_intent

      update_stripe_record_setup_intent(stripe_record_setup_intent)
      stripe_record_subscription = stripe_record_setup_intent.subscription
      return unless stripe_record_subscription

      contract = stripe_record_subscription.current_billing_profile.contract
      return unless contract

      UserStripe::CompleteContractService.new(contract, stripe_record_subscription).execute
    end

    def update_stripe_record_setup_intent(stripe_record_setup_intent)
      stripe_record_setup_intent&.update!(
        status: 'succeeded',
      )
    end
  end
end
