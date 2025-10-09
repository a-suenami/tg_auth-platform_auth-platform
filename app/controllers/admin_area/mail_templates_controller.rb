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
      mail_template = @template.template_mail
      is_new = mail_template.nil?

      # Create or update mail_template
      if mail_template
        mail_template.update!(
          title: params[:title],
          body: params[:body],
        )
      else
        @template.create_template_mail!(
          tenant_id: RequestStore.store[:current_tenant],
          title: params[:title],
          body: params[:body],
        )
      end

      # Log draft_updated if:
      # 1. Has published version
      # 2. Mail template is different from latest version
      # 3. Haven't logged draft_updated for this version yet
      unless is_new
        latest_version = @template.latest_version
        if latest_version
          # Check if content is different from latest version
          content_changed = (mail_template.title.to_s != latest_version.title.to_s) ||
                           (mail_template.body.to_s != latest_version.body.to_s)

          if content_changed
            # Check if already logged draft_updated after latest version
            last_draft_history = @template.mail_template_histories
              .where(event_type: 'draft_updated')
              .order(created_at: :desc)
              .first

            should_log = last_draft_history.nil? ||
                        last_draft_history.created_at < latest_version.created_at

            if should_log
              MailTemplate::History.log_event(
                template: @template,
                event_type: 'draft_updated',
                payload: {
                  user_name: 'Admin'
                }
              )
            end
          end
        end
      end

      flash[:notice] = is_new ? "メールテンプレートを作成しました" : "メールテンプレートを保存しました"
      redirect_to admin_area_template_path(@template)
    rescue => e
      flash[:error] = "エラー: #{e.message}"
      redirect_to admin_area_template_path(@template)
    end

    def publish
      mail_template = @template.mail_template

      unless mail_template
        flash[:error] = "メールテンプレートが存在しません"
        redirect_to admin_area_template_path(@template) and return
      end

      unless mail_template.title.present? && mail_template.body.present?
        flash[:error] = "タイトルと本文を入力してください"
        redirect_to admin_area_template_path(@template) and return
      end

      ActiveRecord::Base.transaction do
        # Calculate next version number
        last_version = @template.mail_template_versions.maximum(:version) || 0
        next_version = last_version + 1
        publish_time = Time.current

        # Create version snapshot (state auto-updates based on this)
        @template.mail_template_versions.create!(
          tenant_id: RequestStore.store[:current_tenant],
          version: next_version,
          title: mail_template.title,
          body: mail_template.body,
          public_started_at: publish_time
        )

        # Log history event
        MailTemplate::History.log_event(
          template: @template,
          event_type: 'published',
          payload: {
            user_name: 'Admin',
            version: next_version,
            published_at: publish_time.iso8601
          }
        )

        flash[:notice] = "メールテンプレートを公開しました（バージョン #{next_version}）"
      end

      redirect_to admin_area_template_path(@template)
    rescue => e
      flash[:error] = "公開エラー: #{e.message}"
      redirect_to admin_area_template_path(@template)
    end

    def schedule
      mail_template = @template.mail_template

      unless mail_template
        flash[:error] = "メールテンプレートが存在しません"
        redirect_to admin_area_template_path(@template) and return
      end

      unless mail_template.title.present? && mail_template.body.present?
        flash[:error] = "タイトルと本文を入力してください"
        redirect_to admin_area_template_path(@template) and return
      end

      scheduled_time_param = params[:public_started_at]

      # Validate presence (handle empty string from form)
      if scheduled_time_param.blank?
        flash[:error] = "公開予定日時を入力してください"
        redirect_to admin_area_template_path(@template) and return
      end

      # Parse ISO8601 string (sent from client in UTC)
      begin
        scheduled_time = Time.iso8601(scheduled_time_param).in_time_zone
      rescue ArgumentError => e
        flash[:error] = "公開予定日時の形式が正しくありません: #{scheduled_time_param}"
        redirect_to admin_area_template_path(@template) and return
      end

      # Validate future time
      if scheduled_time <= Time.current
        flash[:error] = "公開予定日時は未来の日時を指定してください"
        redirect_to admin_area_template_path(@template) and return
      end

      ActiveRecord::Base.transaction do
        latest = @template.latest_version

        # If already scheduled, update existing version
        if latest && latest.public_started_at > Time.current
          latest.update!(public_started_at: scheduled_time)

          # Log rescheduled event
          MailTemplate::History.log_event(
            template: @template,
            event_type: 'rescheduled',
            version: latest,
            payload: {
              user_name: 'Admin',
              version: latest.version,
              scheduled_at: scheduled_time.iso8601
            }
          )

          flash[:notice] = "公開予定日時を変更しました"
        else
          # Create new scheduled version
          last_version = @template.mail_template_versions.maximum(:version) || 0
          next_version = last_version + 1

          @template.mail_template_versions.create!(
            tenant_id: RequestStore.store[:current_tenant],
            version: next_version,
            title: mail_template.title,
            body: mail_template.body,
            public_started_at: scheduled_time
          )

          # Log scheduled event
          MailTemplate::History.log_event(
            template: @template,
            event_type: 'scheduled',
            payload: {
              user_name: 'Admin',
              version: next_version,
              scheduled_at: scheduled_time.iso8601
            }
          )

          flash[:notice] = "公開予約を設定しました"
        end
      end

      redirect_to admin_area_template_path(@template)
    rescue => e
      flash[:error] = "公開予約エラー: #{e.message}"
      redirect_to admin_area_template_path(@template)
    end

    def cancel
      latest = @template.latest_version

      unless latest
        flash[:error] = "公開予約が存在しません"
        redirect_to admin_area_template_path(@template) and return
      end

      unless latest.public_started_at > Time.current
        flash[:error] = "公開予約中のバージョンがありません"
        redirect_to admin_area_template_path(@template) and return
      end

      ActiveRecord::Base.transaction do
        version_number = latest.version

        # Delete the scheduled version
        latest.destroy!

        # Log canceled event
        MailTemplate::History.log_event(
          template: @template,
          event_type: 'canceled',
          payload: {
            user_name: 'Admin',
            version: version_number
          }
        )

        flash[:notice] = "公開予約をキャンセルしました"
      end

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
