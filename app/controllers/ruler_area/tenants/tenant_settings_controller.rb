module RulerArea::Tenants
  class TenantSettingsController < ApplicationController
    def index
      @tenant_settings = TenantSetting.all
      @pagy, @tenant_settings = pagy @tenant_settings
    end

    def show
      @tenant_setting = TenantSetting.find(params[:id])
    end

    def new
      @tenant_setting = TenantSetting.new
    end

    def edit
      @tenant_setting = TenantSetting.find(params[:id])
    end

    def create
      @tenant_setting = TenantSetting.new(tenant_setting_params)
      if @tenant_setting.save
        redirect_to ruler_area_tenant_tenant_settings_path, notice: t('helpers.messages.created')
      else
        render :new, status: :unprocessable_entity
      end
    end


    def update
      @tenant_setting = TenantSetting.find(params[:id])
      if @tenant_setting.update(tenant_setting_params)
        redirect_to ruler_area_tenant_tenant_settings_path, notice: t('helpers.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      tenant_setting = TenantSetting.find(params[:id])
      tenant_setting.destroy!
      redirect_to ruler_area_tenant_tenant_settings_path, notice: t('helpers.messages.destroyed'),  status: :see_other
    end

    private

    def tenant_setting_params
      params.require(:tenant_setting).permit(:google_cloud_service_account, :google_cloud_project_id, :recaptcha_enterprise_checkbox_site_key, :recaptcha_enterprise_score_based_site_key)
    end
  end
end
