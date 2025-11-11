# typed: false

module Templates
  module Mail
    class CancelService < BaseService
      def initialize(template:, actor: nil)
        @template = template
        @actor = actor
      end

      def execute
        validate!

        ActiveRecord::Base.transaction do
          version = @template.latest_version
          version_number = version.version

          @template.template_mail_histories.where(version_id: version.id).update_all(version_id: nil)

          version.destroy!

          log_history(version_number)
        end
      end

      private

      def validate!
        latest = @template.latest_version

        raise '公開予約が存在しません' if latest.nil?

        unless latest.public_started_at > Time.current
          raise '公開予約中のバージョンがありません'
        end
      end

      def log_history(version_number)
        Template::Mail::History.log_event(
          template: @template,
          event_type: 'canceled',
          actor: @actor,
          payload: {
            version: version_number,
          },
        )
      end
    end
  end
end
