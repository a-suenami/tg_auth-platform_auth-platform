# typed: false

module AdminArea
  class TemplatesController < ApplicationController
    MockTemplate = Struct.new(:id, :name, :full_name, :published_version, keyword_init: true)
    MockMailTemplate = Struct.new(:title, :body, :public_started_at, :created_by, :updated_by, :updated_at,
                                  keyword_init: true,)
    MockPagination = Struct.new(:page, :total_count, :pages, :items, :from, :to, :prev, :next, keyword_init: true)

    def index
      # Mock data for Step 1 - UI implementation only
      @templates = mock_templates
      @pagy = mock_pagination
    end

    def show
      @template = find_mock_template(params[:id])
      @mail_template = find_mock_mail_template(params[:id])
      @has_mail_template = @mail_template.present?
      @template_state = determine_state(@mail_template) if @has_mail_template
      @change_history = mock_change_history(params[:id]) if @has_mail_template
    end

    def new
      # Step 1: Just render form, no model needed yet
    end

    def create
      # Mock: Just redirect to template list with flash message
      template_name = params.dig(:template, :name) || params[:name]
      flash[:notice] = "テンプレート「#{template_name}」を作成しました（Mock）"
      redirect_to admin_area_templates_path
    end

    def update_mail_draft
      # Mock: Save mail template draft
      @template = find_mock_template(params[:id])
      flash[:notice] = 'メールテンプレートを保存しました（Mock）'
      redirect_to admin_area_template_path(params[:id])
    end

    private

    MOCK_TEMPLATES_DATA = [
      { id: 1, name: 'バースデーテンプレート', full_name: 'バースデーメッセージテンプレート', published_version: 1 },
      { id: 2, name: 'ブログ更新テンプレート', full_name: 'ブログ更新通知テンプレート', published_version: 100 },
      { id: 3, name: 'チケット更新テンプレート', full_name: 'チケット更新通知テンプレート', published_version: 12 },
      { id: 4, name: 'キャンペーンテンプレート', full_name: 'キャンペーン告知テンプレート', published_version: 2 },
      { id: 5, name: 'チケット先行テンプレート', full_name: 'チケット先行販売テンプレート', published_version: 1 },
    ].freeze

    def mock_templates
      MOCK_TEMPLATES_DATA.map { |data| MockTemplate.new(**data) }
    end

    def format_change_history(histories)
      histories.map do |history|
        {
          icon: event_icon(history.event_type),
          action: event_action(history.event_type),
          user: history.payload['user_name'] || history.payload[:user_name] || 'Unknown',
          timestamp: history.created_at
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
