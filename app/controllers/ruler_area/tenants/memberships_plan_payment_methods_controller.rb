# typed: false

class RulerArea::Tenants::MembershipsPlanPaymentMethodsController < RulerArea::Tenants::ApplicationController
  before_action :set_membership_plan
  before_action :set_plan_payment_method, only: [:edit, :update]

  def edit
  end

  def update
    if @plan_payment_method.update(plan_payment_method_params)
      redirect_to ruler_area_tenant_memberships_plan_path(@tenant_id, @membership_plan), notice: t('helpers.messages.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_membership_plan
    @membership_plan = Memberships::Plan.find(params[:memberships_plan_id])
  end

  def set_plan_payment_method
    @plan_payment_method = @membership_plan.plan_payment_methods.find(params[:id])
  end

  def plan_payment_method_params
    params.require(:memberships_plan_payment_method).permit(:stripe_record_price_id)
  end
end
