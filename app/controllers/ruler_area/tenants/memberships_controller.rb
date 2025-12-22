module RulerArea::Tenants
  class MembershipsController < ApplicationController
    def top
      # メンバーシップ管理のトップページ
    end

    def index
      @memberships = Membership.all
      @pagy, @memberships = pagy @memberships
    end

    def show
      @membership = Membership.find(params[:id])
    end

    def new
      @membership = Membership.new
    end

    def edit
      @membership = Membership.find(params[:id])
    end

    def create
      @membership = Membership.new(membership_params)
      if @membership.save
        redirect_to ruler_area_tenant_memberships_path, notice: t('helpers.messages.created')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @membership = Membership.find(params[:id])
      if @membership.update(membership_params)
        redirect_to ruler_area_tenant_memberships_path, notice: t('helpers.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      membership = Membership.find(params[:id])
      membership.destroy!
      redirect_to ruler_area_tenant_memberships_path, notice: t('helpers.messages.destroyed'), status: :see_other
    end

    private

    def membership_params
      params.require(:membership).permit(
        :name,
        :display_name,
        :position,
        :tier,
      )
    end
  end
end
