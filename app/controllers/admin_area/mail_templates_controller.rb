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

      flash[:notice] = is_new ? 'メールテンプレートを作成しました' : 'メールテンプレートを保存しました'
      redirect_to admin_area_template_path(@template)
    rescue => e
      flash[:error] = "エラー: #{e.message}"
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
