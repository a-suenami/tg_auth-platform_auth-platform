# typed: false

module AdminArea
  class TemplatesController < ApplicationController

    def index
      query = Template
        .includes(:template_mail, :template_mail_versions)
        .ordered
        .search_by_name(params[:q])

      @pagy, @templates = pagy(query, items: 10)
    end

    def show
      @template = Template.includes(
        :template_mail,
        template_mail_histories: :actor,
        template_mail_versions: :published_by,
      ).find(params[:id])
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

    def update
      @template = Template.find(params[:id])

      if @template.update(template_params)
        flash[:notice] = 'テンプレート名を更新しました'
      else
        flash[:error] = @template.errors.full_messages.join(', ')
      end

      redirect_to admin_area_template_path(@template)
    end

    private

    def template_params
      params.require(:template).permit(:name)
    end
  end
end
