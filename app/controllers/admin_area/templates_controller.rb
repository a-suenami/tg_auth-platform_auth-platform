# typed: false

module AdminArea
  class TemplatesController < ApplicationController
    skip_before_action :authenticate!
    before_action :set_tenant_context

    def index
      # Real data from database
      @templates = Template.includes(:mail_template, :mail_template_versions).order(created_at: :desc)
      @pagy = MockPagination.new(page: 1, count: @templates.count, pages: 1, items: @templates.count, from: 1, to: @templates.count, prev: nil, next: nil)
    end

    def show
      @template = Template.includes(:mail_template, :mail_template_histories).find(params[:id])
      @mail_template = @template.mail_template
      @has_mail_template = @mail_template.present?
      @template_state = @template.state
      @change_history = format_change_history(@template.mail_template_histories.ordered) if @has_mail_template
    end

    def new
      # Step 1: Just render form, no model needed yet
    end

    def create
      template_name = params.dig(:template, :name) || params[:name]

      template = Template.create!(
        tenant_id: RequestStore.store[:current_tenant],
        name: template_name,
      )

      flash[:notice] = "テンプレート「#{template_name}」を作成しました"
      redirect_to admin_area_template_path(template)
    rescue => e
      flash[:error] = "エラー: #{e.message}"
      redirect_to admin_area_templates_path
    end

    private

    def set_tenant_context
      RequestStore.store[:current_tenant] = 'sample'
    end

    def format_change_history(histories)
      histories.map do |history|
        {
          icon: event_icon(history.event_type),
          action: event_action(history.event_type),
          user: history.payload['user_name'] || history.payload[:user_name] || 'Unknown',
          timestamp: history.created_at.strftime('%Y/%m/%d %H:%M'),
        }
      end
    end

    def event_icon(event_type)
      case event_type
      when 'draft_created' then '📄'
      when 'draft_updated' then '✏️'
      when 'published' then '🌐'
      when 'scheduled', 'rescheduled' then '📅'
      when 'canceled' then '❌'
      else '📝'
      end
    end

    def event_action(event_type)
      case event_type
      when 'draft_created' then 'が下書きを作成しました'
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
