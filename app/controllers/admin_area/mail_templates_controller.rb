# typed: false

module AdminArea
  class MailTemplatesController < ApplicationController
    skip_before_action :authenticate!
    before_action :set_tenant_context
    before_action :set_template

    def edit
      @mail_template = @template.template_mail

      # Build new mail_template if not exists (not saved yet)
      unless @mail_template
        @mail_template = @template.build_template_mail(
          tenant_id: RequestStore.store[:current_tenant]
        )
      end
    end

    def update
      result = MailTemplates::UpdateService.new(
        template: @template,
        title: params[:title],
        body: params[:body]
      ).execute

      flash[:notice] = result == :created ? "メールテンプレートを作成しました" : "メールテンプレートを保存しました"
      redirect_to admin_area_template_path(@template)
    rescue => e
      flash[:error] = "エラー: #{e.message}"
      redirect_to admin_area_template_path(@template)
    end

    def publish
      version = MailTemplates::PublishService.new(template: @template).execute
      flash[:notice] = "メールテンプレートを公開しました（バージョン #{version.version}）"
      redirect_to admin_area_template_path(@template)
    rescue => e
      flash[:error] = "公開エラー: #{e.message}"
      redirect_to admin_area_template_path(@template)
    end

    def schedule
      result = MailTemplates::ScheduleService.new(
        template: @template,
        scheduled_time_param: params[:public_started_at]
      ).execute

      flash[:notice] = result == :rescheduled ? "公開予定日時を変更しました" : "公開予約を設定しました"
      redirect_to admin_area_template_path(@template)
    rescue => e
      flash[:error] = "公開予約エラー: #{e.message}"
      redirect_to admin_area_template_path(@template)
    end

    def cancel
      MailTemplates::CancelService.new(template: @template).execute
      flash[:notice] = "公開予約をキャンセルしました"
      redirect_to admin_area_template_path(@template)
    rescue => e
      flash[:error] = "キャンセルエラー: #{e.message}"
      redirect_to admin_area_template_path(@template)
    end

    private

    def set_tenant_context
      RequestStore.store[:current_tenant] = 'sample'
    end

    def set_template
      @template = Template.includes(:template_mail).find(params[:template_id])
    end
  end
end
