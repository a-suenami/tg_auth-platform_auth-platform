# typed: false

module Templates
  module Mail
    class PublishService < BaseService
      def initialize(template:, actor: nil)
        @template = template
        @actor = actor
      end

      def execute
        validate!

        ActiveRecord::Base.transaction do
          version = create_version
          log_history(version)
          version
        end
      end

      private

      def validate!
        mail_template = @template.template_mail

        raise 'メールテンプレートが存在しません' if mail_template.nil?

        unless mail_template.title.present? && mail_template.body.present?
          raise 'タイトルと本文を入力してください'
        end
      end

      def create_version
        mail_template = @template.template_mail
        last_version = @template.template_mail_versions.maximum(:version) || 0
        next_version = last_version + 1

        @template.template_mail_versions.create!(
          tenant_id: RequestStore.store[:current_tenant],
          version: next_version,
          title: mail_template.title,
          body: mail_template.body,
          public_started_at: Time.current,
          published_by: @actor,
        )
      end

      def log_history(version)
        Template::Mail::History.log_event(
          template: @template,
          event_type: 'published',
          actor: @actor,
          version: version,
          payload: {
            version: version.version,
          },
        )
      end
    end
  end
end
