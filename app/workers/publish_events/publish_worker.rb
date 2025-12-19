# typed: strict
# frozen_string_literal: true

module PublishEvents
  # Background worker to publish events to AWS EventBridge
  #
  # Enqueued from UserEvent model's after_commit callback.
  # Publishes user-related events (profile changes, address updates, etc.)
  # to EventBridge for downstream consumers.
  #
  # @example
  #   PublishEvents::PublishWorker.perform_async(user_event.id)
  #
  # == EventBridge Event Format
  #
  # EventBridge envelope:
  #   {
  #     source: "com.twogate.idp/{tenant_id}/users",
  #     detail_type: "{resource}.{action}.v1",
  #     detail: { ... },
  #     event_bus_name: Settings.aws.event_bus_name
  #   }
  #
  # detail_type examples:
  #   - user.signed_up.v1
  #   - user.deleted.v1
  #   - profile.registered.v1
  #   - profile.changed.v1
  #   - email.changed.v1
  #   - contact_address.registered.v1
  #   - contact_address.changed.v1
  #   - delivery_address.added.v1
  #   - delivery_address.changed.v1
  #   - delivery_address.removed.v1
  #
  # detail (JSON, snake_case):
  #   {
  #     "event_data": {
  #       "id": "evt_xxxxxxxxxxxx",
  #       "occurred_at": "2025-12-19T10:30:00+09:00",
  #       "params": {
  #         // Parameters that triggered the event
  #         "last_name": "鈴木",
  #         "last_name_kana": "スズキ"
  #       }
  #     },
  #     "resource": {
  #       // Full snapshot of the resource after the change
  #       "user_id": "usr_123456",
  #       "first_name": "太郎",
  #       "last_name": "鈴木",
  #       "first_name_kana": "タロウ",
  #       "last_name_kana": "スズキ",
  #       "birth_date": "1990-01-15",
  #       "gender": "male"
  #     }
  #   }
  #
  class PublishWorker
    include Sidekiq::Worker
    include Sidekiq::Job
    extend T::Sig

    sidekiq_options queue: :default, retry: 3

    # Publish event to EventBridge in background
    #
    # @param user_event_id [String] UserEvent UUID
    sig { params(user_event_id: String).void }
    def perform(user_event_id)
      user_event = UserEvent.find(user_event_id)

      # Set tenant context for multitenancy
      Tenant.current_domain = T.cast(T.must(user_event.tenant).domain, String)

      # TODO: Implement EventBridge publishing
      # 1. Build event payload from user_event
      # 2. Call AWS EventBridge put_events API
      # 3. Handle errors and retries

      Rails.logger.info "PublishWorker: Event #{user_event.event_type} for User #{user_event.user_id} (not yet implemented)"
    end
  end
end
