# typed: false

module PublishEvents
  class PublishService < ::BaseService
    def execute(user:, action_code:)
      client = ::Aws::EventBridge::Client.new(
        region: Settings.aws.region,
        credentials: ::Aws::Credentials.new(Settings.aws.access_key_id, Settings.aws.secret_access_key),
        # ...
      )

      client.put_events({
        entries: [ # required
          {
            source: 'String',
            detail_type: 'String',
            detail: {
              tenant_id: user.tenant_id,
              user_id: user.id,
              action_code:,
              submitted_at: Time.zone.now.to_s,
            }.to_json,
            event_bus_name: 'test-event-bus',
          },
        ],
      })
    end
  end
end
