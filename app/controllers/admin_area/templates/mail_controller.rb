# typed: false

module AdminArea
  module Templates
    class MailController < ApplicationController
      helper AdminArea::TemplatesHelper

      before_action :set_template

      def edit
        @mail_template = @template.template_mail || @template.build_template_mail(
          tenant_id: RequestStore.store[:current_tenant],
        )

        # Auto-generate preview when redirected from save_and_preview
        if params[:tab] == 'preview' && @mail_template.persisted?
          @preview_result = ::Templates::Mail::PreviewService.new.call(
            body: @mail_template.body,
            title: @mail_template.title,
            sample_data: AdminArea::TemplatesHelper::DEFAULT_SAMPLE_DATA,
          )
        end
      end

      def update
        result = ::Templates::Mail::UpdateService.new(
          template: @template,
          title: params[:title],
          body: params[:body],
          actor: current_admin,
        ).execute

        flash[:notice] = result == :created ? 'メールテンプレートを作成しました' : 'メールテンプレートを保存しました'

        if params[:save_and_preview].present?
          redirect_to edit_admin_area_template_mail_path(@template, tab: 'preview')
        else
          redirect_to admin_area_template_path(@template)
        end
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

      def preview
        body = params[:body] || @template.template_mail&.body || ''
        title = params[:title] || @template.template_mail&.title
        sample_data = params[:sample_data]&.to_unsafe_h || {}

        @preview_result = ::Templates::Mail::PreviewService.new.call(
          body: body,
          title: title,
          sample_data: sample_data,
        )

        @mail_template = @template.template_mail || @template.build_template_mail(
          tenant_id: RequestStore.store[:current_tenant],
        )

        render turbo_stream: turbo_stream.update(
          'preview-content',
          partial: 'admin_area/templates/mail/preview_content',
          locals: { mail_template: @mail_template, preview_result: @preview_result },
        )
      end

      private

      def set_template
        @template = Template.includes(:template_mail).find(params[:template_id])
      end
    end
  end
end
