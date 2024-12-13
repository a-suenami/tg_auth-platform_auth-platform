# typed: true

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
      if ::Tenants::CreateService.new(tenant_params).execute
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

    def admin_area
      @tenant = Tenant.find(params[:id])
      Admin.find_or_create_by(tenant_id: @tenant.id, uid: T.must(current_ruler).uid) do |admin|
        admin.email = T.must(current_ruler).email
        admin.name = T.must(current_ruler).name
      end

      scheme = Rails.env.development? ? 'http://' : 'https://'
      host = "#{@tenant.id}.#{Settings.domains.admin}"
      path = admin_area_root_path

      redirect_to "#{scheme}#{host}#{path}", allow_other_host: true
    end

    private

    def tenant_params
      params.require(:tenant).permit(
        :id,
        :name,
        :domain,
        :sms_verification_required,
      )
    end
  end
end
