# typed: false

module AdminArea
  module TemplatesHelper
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
