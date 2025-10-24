# typed: false

class RulerArea::Tenants::MembershipPlansController < RulerArea::Tenants::ApplicationController
  before_action :set_membership_plan, only: [:show, :edit, :update, :destroy]

  def index
    @membership_plans = Membership::Plan.where(tenant_id: @tenant_id)
    @pagy, @membership_plans = pagy @membership_plans
  end

  def show
  end

  def new
    @membership_plan = Membership::Plan.new(tenant_id: @tenant_id)
  end

  def edit
    # クレジットカードの決済方法にマッピングが存在しない場合は空のマッピングを作成
    @membership_plan.plan_payment_methods.where(payment_type: 'credit_card').each do |payment_method|
      next unless payment_method.plan_payment_method_mappings.empty?

      payment_method.plan_payment_method_mappings.build(
        tenant_id: @tenant_id,
        membership_plan_id: @membership_plan.id,
        priceable_type: 'StripeRecord::Price',
      )
    end
  end

  def create
    @membership_plan = Membership::Plan.new(membership_plan_params.except(:plan_payment_methods_attributes))
    @membership_plan.tenant_id = @tenant_id

    ActiveRecord::Base.transaction do
      if @membership_plan.save
        # プラン作成後に決済方法とマッピングを作成
        create_payment_methods_and_mappings
        redirect_to ruler_area_tenant_membership_plans_path, notice: t('helpers.messages.created')
      else
        render :new, status: :unprocessable_entity
      end
    end
  rescue => e
    Rails.logger.error "Error creating membership plan: #{e.message}"
    render :new, status: :unprocessable_entity
  end

  def update
    ActiveRecord::Base.transaction do
      # 既存の決済方法とマッピングを削除
      @membership_plan.plan_payment_methods.destroy_all

      # 新しい決済方法とマッピングを作成
      if @membership_plan.update(membership_plan_params.except(:plan_payment_methods_attributes))
        create_payment_methods_and_mappings
        redirect_to ruler_area_tenant_membership_plans_path, notice: t('helpers.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end
  rescue => e
    Rails.logger.error "Error updating membership plan: #{e.message}"
    render :edit, status: :unprocessable_entity
  end

  def destroy
    @membership_plan.destroy!
    redirect_to ruler_area_tenant_membership_plans_path, notice: t('helpers.messages.destroyed'), status: :see_other
  end

  private

  def set_membership_plan
    @membership_plan = Membership::Plan.find(params[:id])
  end

  def create_payment_methods_and_mappings
    payment_methods_params = params[:membership_plan][:plan_payment_methods_attributes]
    return unless payment_methods_params

    payment_methods_params.each do |payment_method_param|
      next if payment_method_param[:_destroy] == '1'

      # 決済方法を作成
      payment_method = @membership_plan.plan_payment_methods.create!(
        tenant_id: @tenant_id,
        payment_type: payment_method_param[:payment_type],
      )

      # マッピングを作成（クレジットカードの場合のみ）
      next unless payment_method_param[:payment_type] == 'credit_card'

      mappings_params = payment_method_param[:plan_payment_method_mappings_attributes]
      next unless mappings_params

      mappings_params.each do |mapping_param|
        next if mapping_param[:_destroy] == '1'

        payment_method.plan_payment_method_mappings.create!(
          tenant_id: @tenant_id,
          membership_plan_id: @membership_plan.id,
          priceable_id: mapping_param[:priceable_id],
          priceable_type: mapping_param[:priceable_type],
          amount: mapping_param[:amount],
          currency: mapping_param[:currency],
        )
      end
    end
  end

  def membership_plan_params
    params.require(:membership_plan).permit(
      :name,
      :recurrence,
      :recurring_interval_unit,
      :recurring_interval_count,
      :billing_anchor,
      :anchor_day_of_month,
      :amount,
      :trial_period_days,
      :position,
      :enabled_at,
      :disabled_at,
      plan_payment_methods_attributes: [
        :id, :payment_type, :_destroy,
        plan_payment_method_mappings_attributes: [:id, :priceable_id, :priceable_type, :amount, :currency, :membership_plan_id, :tenant_id, :_destroy],
      ],
      plan_components_attributes: [:id, :membership_id, :tenant_id, :_destroy],
    ).merge(tenant_id: @tenant_id)
  end
end
