module RulerArea::Tenants
  class ShopifyMultipassSettingsController < ApplicationController
    def index
      @multipass_settings = ShopifyRecord::MultipassSetting.all
      @pagy, @multipass_settings = pagy @multipass_settings
    end

    def show
      @multipass_setting = ShopifyRecord::MultipassSetting.find(params[:id])
    end

    def new
      @multipass_setting = ShopifyRecord::MultipassSetting.new
    end

    def edit
      @multipass_setting = ShopifyRecord::MultipassSetting.find(params[:id])
    end

    def create
      @multipass_setting = ShopifyRecord::MultipassSetting.new(multipass_setting_params)
      if @multipass_setting.save
        redirect_to ruler_area_tenant_shopify_multipass_settings_path, notice: t('helpers.messages.created')
      else
        render :new, status: :unprocessable_entity
      end
    end


    def update
      @multipass_setting = ShopifyRecord::MultipassSetting.find(params[:id])
      if @multipass_setting.update(multipass_setting_params)
        redirect_to ruler_area_tenant_shopify_multipass_settings_path, notice: t('helpers.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      multipass_setting = ShopifyRecord::MultipassSetting.find(params[:id])
      multipass_setting.destroy!
      redirect_to ruler_area_tenant_shopify_multipass_settings_path, notice: t('helpers.messages.destroyed'),  status: :see_other
    end

    private

    def multipass_setting_params
      params.require(:shopify_record_multipass_setting).permit(
        :store_url,
        :store_name,
        :api_key,
        :oauth_client_id,
        :scopes,
        :multipass_secret,
        :webhook_token,
      )
    end
  end
end
