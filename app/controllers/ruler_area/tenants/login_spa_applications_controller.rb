module RulerArea::Tenants
  class LoginSpaApplicationsController < ApplicationController
    before_action :set_login_spa_application

    def show; end

    def edit; end

    def update
      if @login_spa_application.update(login_spa_application_params)
        redirect_to ruler_area_tenant_login_spa_application_path(@tenant_id), notice: t('helpers.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_login_spa_application
      @login_spa_application = LoginSpaApplication.find_or_initialize_by(tenant_id: @tenant_id) do |lsa|
        lsa.name = 'Default'
        lsa.uid = SecureRandom.uuid
        lsa.login_url = "http://#{Tenant.find(@tenant_id).domain}:3000/my"
        lsa.redirect_url_on_password_reset = "http://#{Tenant.find(@tenant_id).domain}:3000/login"
      end
    end

    def login_spa_application_params
      params.require(:login_spa_application).permit(
        :name, :login_url, :sign_up_url, :redirect_url_on_password_reset, :confidential, :scopes,
        :enable_web_login, :enable_web_sign_up,
      )
    end
  end
end
