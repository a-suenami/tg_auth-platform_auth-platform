# typed: false

class RulerArea::Tenants::MembershipsPlansController < RulerArea::Tenants::ApplicationController
  before_action :set_membership_plan, only: [:show, :edit, :update, :destroy]

  def index
    @membership_plans = Memberships::Plan.where(tenant_id: @tenant_id)
    @pagy, @membership_plans = pagy @membership_plans
  end

  def show
  end

  def new
    @membership_plan = Memberships::Plan.new(tenant_id: @tenant_id)
  end

  def edit
  end

  def create
    @membership_plan = Memberships::Plan.new(membership_plan_params)
    @membership_plan.tenant_id = @tenant_id

    if @membership_plan.save
      redirect_to ruler_area_tenant_memberships_plans_path, notice: t('helpers.messages.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @membership_plan.update(membership_plan_params)
      redirect_to ruler_area_tenant_memberships_plans_path, notice: t('helpers.messages.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @membership_plan.destroy!
    redirect_to ruler_area_tenant_memberships_plans_path, notice: t('helpers.messages.destroyed'), status: :see_other
  end

  private

  def set_membership_plan
    @membership_plan = Memberships::Plan.find(params[:id])
  end

  def membership_plan_params
    params.require(:memberships_plan).permit(
      :name,
      :recurrence,
      :recurring_interval_unit,
      :recurring_interval_count,
      :billing_anchor,
      :anchor_day_of_month,
      :amount,
      :trial_period_days,
      :enabled_at,
      :disabled_at,
      plan_payment_methods_attributes: [:id, :payment_type, :stripe_record_price_id, :_destroy],
      plan_components_attributes: [:id, :membership_id, :tenant_id, :_destroy],
    ).merge(tenant_id: @tenant_id)
  end
end
