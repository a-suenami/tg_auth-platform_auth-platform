# typed: false

module AdminArea
  module Templates
    class MailController < ApplicationController
      before_action :set_template

      def edit
        @mail_template = @template.template_mail || @template.build_template_mail(
          tenant_id: RequestStore.store[:current_tenant],
        )
      end

      def update
        result = ::Templates::Mail::UpdateService.new(
          template: @template,
          title: params[:title],
          body: params[:body],
          actor: current_admin,
        ).execute

        flash[:notice] = result == :created ? 'メールテンプレートを作成しました' : 'メールテンプレートを保存しました'
        redirect_to admin_area_template_path(@template)
      rescue => e
        flash[:error] = "エラー: #{e.message}"
        redirect_to admin_area_template_path(@template)
      end

      def publish
        version = ::Templates::Mail::PublishService.new(
          template: @template,
          actor: current_admin,
        ).execute
        flash[:notice] = "メールテンプレートを公開しました（バージョン #{version.version}）"
        redirect_to admin_area_template_path(@template)
      rescue => e
        flash[:error] = "公開エラー: #{e.message}"
        redirect_to admin_area_template_path(@template)
      end

      def schedule
        result = ::Templates::Mail::ScheduleService.new(
          template: @template,
          scheduled_time_param: params[:public_started_at],
          actor: current_admin,
        ).execute

        flash[:notice] = result == :rescheduled ? '公開予定日時を変更しました' : '公開予約を設定しました'
        redirect_to admin_area_template_path(@template)
      rescue => e
        flash[:error] = "公開予約エラー: #{e.message}"
        redirect_to admin_area_template_path(@template)
      end

      def cancel
        ::Templates::Mail::CancelService.new(
          template: @template,
          actor: current_admin,
        ).execute
        flash[:notice] = '公開予約をキャンセルしました'
        redirect_to admin_area_template_path(@template)
      rescue => e
        flash[:error] = "キャンセルエラー: #{e.message}"
        redirect_to admin_area_template_path(@template)
      end

      private

      def set_template
        @template = Template.includes(:template_mail).find(params[:template_id])
      end
    end
  end
end
