# typed: strict

class UserAutoTagging
  # Background worker to handle auto-tagging events for a single user
  #
  # Called when user data changes (profile update, address change, etc.)
  # Processes auto-tagging rules asynchronously to avoid blocking the request.
  #
  # @example Profile updated
  #   UserAutoTagging::EventWorker.perform_async(user.id, 'profile_updated')
  #
  class EventWorker
    include Sidekiq::Worker
    include Sidekiq::Job
    extend T::Sig

    sidekiq_options queue: :default, retry: 3

    # Handle auto-tagging event in background
    #
    # @param user_id [String] User UUID
    # @param event_type [String] Event type string (will be converted to symbol)
    sig { params(user_id: String, event_type: String).void }
    def perform(user_id, event_type)
      user = User.find(user_id)

      # Set tenant context for multitenancy
      Tenant.current_domain = T.cast(T.must(user.tenant).domain, String)

      # Convert string to symbol for event type
      event = event_type.to_sym

      # Execute service
      service = UserAutoTagging::EventHandlerService.new
      result = service.execute(user: user, event: event)

      Rails.logger.info "EventWorker completed for User #{user_id}, event #{event_type}: #{result.inspect}"
    end
  end
end
