# typed: false

module MailTemplates
  class CancelService < BaseService
    def initialize(template:)
      @template = template
    end

    def execute
      validate!

      ActiveRecord::Base.transaction do
        version_number = @template.latest_version.version
        @template.latest_version.destroy!

        log_history(version_number)
      end
    end

    private

    def validate!
      latest = @template.latest_version

      raise "公開予約が存在しません" if latest.nil?

      unless latest.public_started_at > Time.current
        raise "公開予約中のバージョンがありません"
      end
    end

    def log_history(version_number)
      MailTemplate::History.log_event(
        template: @template,
        event_type: 'canceled',
        payload: {
          user_name: 'Admin',
          version: version_number
        }
      )
    end
  end
end
