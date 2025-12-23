# frozen_string_literal: true

module RulerArea::Tenants
  class OauthProvidersController < ApplicationController
    def index
      @oauth_providers = OauthProvider.all
      @pagy, @oauth_providers = pagy @oauth_providers
    end

    def show
      @oauth_provider = OauthProvider.find(params[:id])
    end

    def new
      @oauth_provider = OauthProvider.new
    end

    def edit
      @oauth_provider = OauthProvider.find(params[:id])
    end

    def create
      @oauth_provider = OauthProvider.new(oauth_provider_params)
      if @oauth_provider.save
        redirect_to ruler_area_tenant_oauth_provider_path(@tenant_id, @oauth_provider), notice: t('helpers.messages.created')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @oauth_provider = OauthProvider.find(params[:id])
      if @oauth_provider.update(oauth_provider_params)
        redirect_to ruler_area_tenant_oauth_provider_path(@tenant_id, @oauth_provider), notice: t('helpers.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      oauth_provider = OauthProvider.find(params[:id])
      oauth_provider.destroy!
      redirect_to ruler_area_tenant_oauth_providers_path(@tenant_id), notice: t('helpers.messages.destroyed'), status: :see_other
    end

    private

    def oauth_provider_params
      params.require(:oauth_provider).permit(:provider, :client_id, :client_secret, :auth_url, :token_url, :user_info_url, :scopes)
    end
  end
end
