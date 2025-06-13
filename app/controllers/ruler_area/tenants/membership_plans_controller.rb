module RulerArea::Tenants
  class MembershipPlansController < ApplicationController
    def index
      @membership_plans = Memberships::Plan.all
      @pagy, @membership_plans = pagy @membership_plans
    end

    def show
      @membership_plan = Memberships::Plan.find(params[:id])
    end

    def new
      @membership_plan = Memberships::Plan.new(tenant_id: @tenant_id)
    end

    def edit
      @membership_plan = Memberships::Plan.find(params[:id])
    end

    def create
      @membership_plan = Memberships::Plan.new(membership_plan_params)
      @membership_plan.tenant_id = @tenant_id

      # membership_idを設定（最初のメンバーシップを使用）
      if @membership_plan.membership_id.blank?
        first_membership = Membership.where(tenant_id: @tenant_id).first
        @membership_plan.membership_id = first_membership&.id
      end

      if @membership_plan.save
        redirect_to ruler_area_tenant_membership_plans_path, notice: t('helpers.messages.created')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @membership_plan = Memberships::Plan.find(params[:id])

      if @membership_plan.update(membership_plan_params)
        redirect_to ruler_area_tenant_membership_plans_path, notice: t('helpers.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      membership_plan = Memberships::Plan.find(params[:id])
      membership_plan.destroy!
      redirect_to ruler_area_tenant_membership_plans_path, notice: t('helpers.messages.destroyed'), status: :see_other
    end

    private

    def membership_plan_params
      params.require(:memberships_plan).permit(
        :name,
        :membership_id,
        :billing_cycle,
        :validity_period,
        :amount,
        :enabled_at,
        :disabled_at,
        plan_payment_methods_attributes: [:id, :payment_type, :_destroy],
      )
    end
  end
end
