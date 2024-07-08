module RulerArea::Tenants
  class AdminsController < ApplicationController
    def index
      @admins = Admin.all
      @pagy, @admins = pagy @admins
    end

    def new
      @admin = Admin.new
    end

    def create
      if ::Admins::CreateService.new.execute(email: admin_params[:email], name: admin_params[:name])
        redirect_to ruler_area_tenant_admins_path, notice: t('helpers.messages.created')
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def admin_params
      params.require(:admin).permit(
        :name,
        :email,
      )
    end
  end
end
