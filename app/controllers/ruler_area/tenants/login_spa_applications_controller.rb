module RulerArea::Tenants
  class LoginSpaApplicationsController < ApplicationController
    def index
      @login_spa_applications = LoginSpaApplication.all
      @pagy, @login_spa_applications = pagy @login_spa_applications
    end

    def show
      @login_spa_application = LoginSpaApplication.find(params[:id])
    end

    def new
      @login_spa_application = LoginSpaApplication.new
    end

    def edit
      @login_spa_application = LoginSpaApplication.find(params[:id])
    end

    def create
      @login_spa_application = LoginSpaApplication.new(login_spa_application_params)
      @login_spa_application.uid = SecureRandom.uuid
      if @login_spa_application.save
        redirect_to ruler_area_tenant_login_spa_applications_path, notice: t('helpers.messages.created')
      else
        render :new, status: :unprocessable_entity
      end
    end


    def update
      @login_spa_application = LoginSpaApplication.find(params[:id])
      if @login_spa_application.update(login_spa_application_params)
        redirect_to ruler_area_tenant_login_spa_applications_path, notice: t('helpers.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      login_spa_application = LoginSpaApplication.find(params[:id])
      login_spa_application.destroy!
      redirect_to ruler_area_tenant_login_spa_applications_path, notice: t('helpers.messages.destroyed'),  status: :see_other
    end

    private

    def login_spa_application_params
      params.require(:login_spa_application).permit(:name, :login_url, :sign_up_url, :redirect_url_on_password_reset)
    end
  end
end
