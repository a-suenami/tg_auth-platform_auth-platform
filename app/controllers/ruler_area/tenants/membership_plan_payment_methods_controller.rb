# typed: false

class RulerArea::Tenants::MembershipPlanPaymentMethodsController < RulerArea::Tenants::ApplicationController
  before_action :set_membership_plan
  before_action :set_plan_payment_method, only: [:edit, :update]

  def edit
  end

  def update
    mapping_id = params[:mapping_id]
    mapping = @plan_payment_method.plan_payment_method_mappings.find(mapping_id)

    if mapping.update(plan_payment_method_mapping_params)
      redirect_to ruler_area_tenant_membership_plan_path(@tenant_id, @membership_plan), notice: t('helpers.messages.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_membership_plan
    @membership_plan = Membership::Plan.find(params[:membership_plan_id])
  end

  def set_plan_payment_method
    @plan_payment_method = @membership_plan.plan_payment_methods.find(params[:id])
  end

  def plan_payment_method_mapping_params
    params.permit(:priceable_id, :amount, :currency)
  end
end
