module RulerArea
  class TenantsController < ApplicationController
    def index
      @tenants = Tenant.all
      @pagy, @tenants = pagy @tenants
    end

    def show
      @tenant = Tenant.find(params[:id])
    end

    def new
      @tenant = Tenant.new
    end

    def edit
      @tenant = Tenant.find(params[:id])
    end

    def create
      @tenant = Tenant.new(tenant_params)
      if @tenant.save
        redirect_to ruler_area_tenants_path, notice: t('helpers.messages.created')
      else
        render :new, status: :unprocessable_entity
      end
    end


    def update
      @tenant = Tenant.find(params[:id])
      if @tenant.update(tenant_params)
        redirect_to ruler_area_tenants_path, notice: t('helpers.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def tenant_params
      params.require(:tenant).permit(:id, :name, :domain)
    end
  end
end
