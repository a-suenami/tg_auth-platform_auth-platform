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

    sig { params(user_event_id: String).void }
    def perform(user_event_id)
      return if skip_publishing?

      user_event = UserEvent.find(user_event_id)
      Tenant.current_domain = T.cast(T.must(user_event.tenant).domain, String)

      put_event(user_event:)
    end

    private

    sig { params(user_event: UserEvent).void }
    def put_event(user_event:)
      # Sample implementation: user_tag.added.v1
      eventbridge_client.put_events({
        entries: [
          {
            source: "com.twogate.idp/#{user_event.tenant_id}/users",
            detail_type: 'user_tag.added.v1',
            detail: build_detail(user_event:).to_json,
            event_bus_name: Settings.aws.event_bus_name,
          },
        ],
      })

      Rails.logger.info "PublishWorker: Published event user_tag.added.v1 for UserEvent #{user_event.id}"
    end

    sig { params(user_event: UserEvent).returns(T::Hash[Symbol, T.untyped]) }
    def build_detail(user_event:)
      {
        event_data: {
          id: user_event.id,
          occurred_at: user_event.created_at&.iso8601,
          # TODO: Replace with actual data from user_event.payload
          tag_id: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
          display_name: 'Sample Tag',
          assignment_type: 'manual', # or 'auto'
        },
        # TODO: Replace with actual user snapshot (see PublishService#user_json)
        resource: {
          uid: user_event.user_id,
          email: 'sample@example.com',
          phone_number: '090-0000-0000',
          deleted_at: nil,
          profile: {
            first_name: 'Taro',
            last_name: 'Yamada',
            first_name_kana: 'タロウ',
            last_name_kana: 'ヤマダ',
            birth_date: '1990-01-01',
            gender: 'male',
          },
          contact_address: {
            prefecture_code: '13',
            prefecture: '東京都',
            zip_code: '100-0001',
            city: '千代田区',
            street: '千代田1-1',
            building: nil,
            country_code: 'JP',
            phone_number: '03-0000-0000',
          },
          delivery_addresses: [],
          tags: [
            { id: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx', name: 'Sample Tag' },
          ],
        },
      }
    end

    sig { returns(T::Boolean) }
    def skip_publishing?
      Settings.aws&.region.blank? || Settings.aws&.event_bus_name.blank?
    end

    # TODO: Extract to lib/ or app/lib/ as a shared EventBridge client
    sig { returns(Aws::EventBridge::Client) }
    def eventbridge_client
      @eventbridge_client ||= T.let(
        Aws::EventBridge::Client.new(region: Settings.aws.region, credentials: aws_credentials),
        T.nilable(Aws::EventBridge::Client),
      )
    end

    sig { returns(T.any(Aws::Credentials, Aws::ECSCredentials)) }
    def aws_credentials
      if Settings.aws.access_key_id
        Aws::Credentials.new(Settings.aws.access_key_id, Settings.aws.secret_access_key)
      else
        Aws::ECSCredentials.new
      end
    end
  end
end
