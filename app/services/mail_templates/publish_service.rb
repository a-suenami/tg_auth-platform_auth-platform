# typed: false

module MailTemplates
  class PublishService < BaseService
    def initialize(template:)
      @template = template
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
      mail_template = @template.mail_template

      raise "メールテンプレートが存在しません" if mail_template.nil?

      unless mail_template.title.present? && mail_template.body.present?
        raise "タイトルと本文を入力してください"
      end
    end

    def create_version
      mail_template = @template.mail_template
      last_version = @template.mail_template_versions.maximum(:version) || 0
      next_version = last_version + 1

      @template.mail_template_versions.create!(
        tenant_id: RequestStore.store[:current_tenant],
        version: next_version,
        title: mail_template.title,
        body: mail_template.body,
        public_started_at: Time.current
      )
    end

    def log_history(version)
      MailTemplate::History.log_event(
        template: @template,
        event_type: 'published',
        payload: {
          user_name: 'Admin',
          version: version.version
        }
      )
    end
  end
end
