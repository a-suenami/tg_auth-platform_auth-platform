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

    def find_mock_template(id)
      template_data = MOCK_TEMPLATES_DATA.find { |t| t[:id] == id.to_i }
      template_data ||= MOCK_TEMPLATES_DATA.first
      MockTemplate.new(**template_data)
    end

    def find_mock_mail_template(id)
      # Mock different states based on template_id
      case id.to_i
      when 1
        MockMailTemplate.new(
          title: 'Welcome Email',
          body: 'Hello {{user_name}}, welcome!',
          public_started_at: nil, # Draft
          created_by: 'Yamada TARO',
          updated_by: 'Yamada TARO',
          updated_at: '2025/09/27 12:00',
        )
      when 3
        MockMailTemplate.new(
          title: 'Campaign Email',
          body: 'Special campaign for you!',
          public_started_at: Time.zone.parse('2025/09/29 12:00'), # Scheduled
          created_by: 'Yamada TARO',
          updated_by: 'Yamada TARO',
          updated_at: '2025/09/27 12:00',
        )
      when 4
        MockMailTemplate.new(
          title: 'Newsletter',
          body: 'Monthly newsletter content',
          public_started_at: Time.zone.parse('2025/09/15 10:00'), # Published
          created_by: 'Yamada TARO',
          updated_by: 'Yamada TARO',
          updated_at: '2025/09/15 10:00',
        )
      end
    end

    def determine_state(mail_template)
      return :no_template unless mail_template
      return :draft if mail_template.public_started_at.nil?
      return :scheduled if mail_template.public_started_at > Time.current

      :published
    end

    def mock_change_history(id)
      case id.to_i
      when 1 # Draft
        [
          { icon: '✏️', action: 'が下書きを編集しました', user: 'Yamada TARO', timestamp: '2025/09/18 12:00' },
          { icon: '📄', action: 'がメールテンプレートを作成しました', user: 'Yamada TARO', timestamp: '2025/09/18 12:00' },
        ]
      when 3 # Scheduled
        [
          { icon: '📅', action: 'が公開予約をしました', user: 'Yamada TARO', timestamp: '2025/09/19 12:00' },
          { icon: '✏️', action: 'が下書きを編集しました', user: 'Yamada TARO', timestamp: '2025/09/18 12:00' },
          { icon: '📄', action: 'が下書きを作成しました', user: 'Yamada TARO', timestamp: '2025/09/18 12:00' },
        ]
      when 4 # Published
        [
          { icon: '🌐', action: 'が公開しました', user: 'Yamada TARO', timestamp: '2025/09/15 10:00' },
          { icon: '📄', action: 'が下書きを作成しました', user: 'Yamada TARO', timestamp: '2025/09/15 09:00' },
        ]
      else
        []
      end
    end

    def mock_pagination
      MockPagination.new(
        page: 1,
        total_count: 999,
        pages: 20,
        items: 50,
        from: 1,
        to: 50,
        prev: nil,
        next: 2,
      )
    end
  end
end
