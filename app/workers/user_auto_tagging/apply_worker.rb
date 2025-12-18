# typed: strict

class UserAutoTagging
  # Background worker to apply auto-tagging rules to all matching users
  #
  # @example
  #   UserAutoTagging::ApplyWorker.perform_async(user_auto_tagging_id)
  #
  class ApplyWorker
    include Sidekiq::Worker
    include Sidekiq::Job
    extend T::Sig

    sidekiq_options queue: :default, retry: 3

    # Apply auto-tagging rules in background
    #
    # @param user_auto_tagging_id [String] UserAutoTagging UUID
    sig { params(user_auto_tagging_id: String).void }
    def perform(user_auto_tagging_id)
      user_auto_tagging = UserAutoTagging.find(user_auto_tagging_id)

      # Set tenant context for multitenancy
      Tenant.current_domain = T.cast(T.must(user_auto_tagging.tenant).domain, String)

      # Execute service
      service = UserAutoTagging::ApplyService.new
      result = service.execute(user_auto_tagging)

      Rails.logger.info "ApplyWorker completed for UserAutoTagging #{user_auto_tagging_id}: #{result.inspect}"
    end
  end
end
