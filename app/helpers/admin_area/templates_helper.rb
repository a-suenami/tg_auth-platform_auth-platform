# typed: false

module AdminArea
  module TemplatesHelper
    # Default sample data for email template preview
    DEFAULT_SAMPLE_DATA = {
      'first_name' => '太郎',
      'last_name' => '山田',
    }.freeze

    # Allowed HTML tags for email templates (XSS protection)
    ALLOWED_EMAIL_TAGS = %w[
      p br div span
      h1 h2 h3 h4 h5 h6
      strong b em i u s
      a ul ol li
      table thead tbody tr th td
      img hr blockquote pre code
    ].freeze

    ALLOWED_EMAIL_ATTRIBUTES = %w[
      href src alt width height style class
      target title border cellpadding cellspacing
      colspan rowspan align valign
    ].freeze

    # Sanitize HTML for safe email template rendering
    def sanitize_email_html(html)
      return ''.html_safe if html.blank?

      sanitize(html, tags: ALLOWED_EMAIL_TAGS, attributes: ALLOWED_EMAIL_ATTRIBUTES)
    end

    # Status badge helpers
    def status_label_class(state)
      case state
      when :draft then 'uk-label-warning'
      when :scheduled then 'uk-label-primary'
      when :published then 'uk-label-success'
      else 'uk-label-default'
      end
    end

    def status_label_text(state)
      case state
      when :draft then '下書き'
      when :scheduled then '公開予定中'
      when :published then '公開中'
      when :no_template then '未作成'
      else '不明'
      end
    end

    def format_change_history(histories)
      histories.map do |history|
        {
          icon: event_icon(history.event_type),
          action: event_action(history.event_type),
          user: history.actor&.name || 'Unknown',
          timestamp: history.created_at,
        }
      end
    end

    def event_icon(event_type)
      case event_type
      when 'draft_updated' then '✏️'
      when 'published' then '🌐'
      when 'scheduled', 'rescheduled' then '📅'
      when 'canceled' then '❌'
      else '📝'
      end
    end

    def event_action(event_type)
      case event_type
      when 'draft_updated' then 'が下書きを編集しました'
      when 'published' then 'が公開しました'
      when 'scheduled' then 'が公開予約をしました'
      when 'rescheduled' then 'が公開予約を変更しました'
      when 'canceled' then 'が公開をキャンセルしました'
      else 'が操作を実行しました'
      end
    end
  end
end
