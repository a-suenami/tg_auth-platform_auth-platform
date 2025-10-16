# typed: false

module Templates
  module Mail
    class UpdateService < BaseService
      def initialize(template:, title:, body:, actor: nil)
        @template = template
        @title = title
        @body = body
        @actor = actor
      end

      def execute
        mail_template = @template.template_mail
        is_new = mail_template.nil?

        if mail_template
          update_mail_template(mail_template)
        else
          mail_template = create_mail_template
        end

        track_draft_changes(mail_template) unless is_new

        is_new ? :created : :updated
      end

      private

      def create_mail_template
        @template.create_template_mail!(
          tenant_id: RequestStore.store[:current_tenant],
          title: @title,
          body: @body,
        )
      end

      def update_mail_template(mail_template)
        mail_template.update!(
          title: @title,
          body: @body,
        )
      end

      def track_draft_changes(mail_template)
        latest_version = @template.latest_version
        return unless latest_version

        if content_changed?(mail_template, latest_version) && should_log_draft_update?(latest_version)
          log_draft_updated
        end
      end

      def content_changed?(mail_template, latest_version)
        mail_template.title.to_s != latest_version.title.to_s ||
          mail_template.body.to_s != latest_version.body.to_s
      end

      def should_log_draft_update?(latest_version)
        last_draft_history = @template.template_mail_histories
          .where(event_type: 'draft_updated')
          .order(created_at: :desc)
          .first

        last_draft_history.nil? || last_draft_history.created_at < latest_version.created_at
      end

      def log_draft_updated
        Template::Mail::History.log_event(
          template: @template,
          event_type: 'draft_updated',
          actor: @actor,
          payload: {
            title: @title,
            body: @body,
          },
        )
      end
    end
  end
end
