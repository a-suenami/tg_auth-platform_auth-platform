module RulerArea::Tenants
  class ShopifyMultipassStoresController < ApplicationController
    def index
      @multipass_stores = ShopifyRecord::MultipassStore.all
      @pagy, @multipass_stores = pagy @multipass_stores
    end

    def show
      @multipass_store = ShopifyRecord::MultipassStore.find(params[:id])
    end

    def new
      @multipass_store = ShopifyRecord::MultipassStore.new
    end

    def edit
      @multipass_store = ShopifyRecord::MultipassStore.find(params[:id])
    end

    def create
      @multipass_store = ShopifyRecord::MultipassStore.new(multipass_store_params)
      if @multipass_store.save
        redirect_to ruler_area_tenant_shopify_multipass_stores_path, notice: t('helpers.messages.created')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @multipass_store = ShopifyRecord::MultipassStore.find(params[:id])
      if @multipass_store.update(multipass_store_params)
        redirect_to ruler_area_tenant_shopify_multipass_stores_path, notice: t('helpers.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      multipass_store = ShopifyRecord::MultipassStore.find(params[:id])
      multipass_store.destroy!
      redirect_to ruler_area_tenant_shopify_multipass_stores_path, notice: t('helpers.messages.destroyed'),  status: :see_other
    end

    private

    def multipass_store_params
      params.require(:shopify_record_multipass_store).permit(
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
