# typed: false

module MailTemplates
  class ScheduleService < BaseService
    def initialize(template:, scheduled_time_param:)
      @template = template
      @scheduled_time_param = scheduled_time_param
    end

    def execute
      validate!
      scheduled_time = parse_time

      ActiveRecord::Base.transaction do
        if rescheduling?
          reschedule(scheduled_time)
        else
          create_scheduled_version(scheduled_time)
        end
      end
    end

    private

    def validate!
      mail_template = @template.mail_template

      raise "メールテンプレートが存在しません" if mail_template.nil?

      unless mail_template.title.present? && mail_template.body.present?
        raise "タイトルと本文を入力してください"
      end

      raise "公開予定日時を入力してください" if @scheduled_time_param.blank?
    end

    def parse_time
      scheduled_time = Time.iso8601(@scheduled_time_param).in_time_zone

      if scheduled_time <= Time.current
        raise "公開予定日時は未来の日時を指定してください"
      end

      scheduled_time
    rescue ArgumentError
      raise "公開予定日時の形式が正しくありません: #{@scheduled_time_param}"
    end

    def rescheduling?
      latest = @template.latest_version
      latest && latest.public_started_at > Time.current
    end

    def reschedule(scheduled_time)
      latest = @template.latest_version
      latest.update!(public_started_at: scheduled_time)

      MailTemplate::History.log_event(
        template: @template,
        event_type: 'rescheduled',
        version: latest,
        payload: {
          user_name: 'Admin',
          version: latest.version,
          scheduled_at: scheduled_time.iso8601
        }
      )

      :rescheduled
    end

    def create_scheduled_version(scheduled_time)
      mail_template = @template.mail_template
      last_version = @template.mail_template_versions.maximum(:version) || 0
      next_version = last_version + 1

      version = @template.mail_template_versions.create!(
        tenant_id: RequestStore.store[:current_tenant],
        version: next_version,
        title: mail_template.title,
        body: mail_template.body,
        public_started_at: scheduled_time
      )

      MailTemplate::History.log_event(
        template: @template,
        event_type: 'scheduled',
        payload: {
          user_name: 'Admin',
          version: next_version,
          scheduled_at: scheduled_time.iso8601
        }
      )

      :scheduled
    end
  end
end
