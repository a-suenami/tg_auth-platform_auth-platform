module RulerArea::Tenants
  class OauthApplicationsController < ApplicationController
    def index
      @oauth_applications = OauthApplication.all
      @pagy, @oauth_applications = pagy @oauth_applications
    end

    def show
      @oauth_application = OauthApplication.find(params[:id])
    end

    def new
      @oauth_application = OauthApplication.new
    end

    def edit
      @oauth_application = OauthApplication.find(params[:id])
    end

    def create
      @oauth_application = OauthApplication.create(oauth_application_params)
      if @oauth_application.persisted?
        redirect_to ruler_area_tenant_oauth_application_path(@oauth_application.tenant_id, @oauth_application), notice: t('helpers.messages.created')
      else
        render :new, status: :unprocessable_entity
      end
    end


    def update
      @oauth_application = OauthApplication.find(params[:id])
      if @oauth_application.update(oauth_application_params)
        redirect_to ruler_area_tenant_oauth_application_path(@oauth_application.tenant_id, @oauth_application), notice: t('helpers.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      oauth_application = OauthApplication.find(params[:id])
      oauth_application.destroy!
      redirect_to ruler_area_tenant_oauth_applications_path, notice: t('helpers.messages.destroyed'),  status: :see_other
    end

    private

    def oauth_application_params
      params.require(:oauth_application).permit(:name, :redirect_uri, :scopes, :confidential, :enable_client_credential_flow, :enable_push_event, :require_sms_mfa, :allowed_logout_urls)
    end
  end
end
