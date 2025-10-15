# typed: false

module AdminArea
  class TemplatesController < ApplicationController
    MockPagination = Struct.new(:page, :total_count, :pages, :items, :from, :to, :prev, :next, keyword_init: true)

    def index
      @templates = Template.includes(:template_mail, :template_mail_versions).order(created_at: :desc)
      @pagy = mock_pagination
    end

    def show
      @template = Template.includes(:template_mail, :template_mail_histories).find(params[:id])
      @mail_template = @template.template_mail
      @has_template_mail = @mail_template.present?
      @template_state = @template.state
      @histories = @template.template_mail_histories.ordered if @has_template_mail
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

    def mock_pagination
      MockPagination.new(
        page: 1,
        total_count: @templates.size,
        pages: 1,
        from: @templates.empty? ? 0 : 1,
        to: @templates.size,
        prev: nil,
        next: nil,
        items: @templates,
      )
    end
  end
end
