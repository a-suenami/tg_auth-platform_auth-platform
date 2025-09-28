# typed: false

class RulerArea::Tenants::MembershipsGroupsController < RulerArea::Tenants::ApplicationController
  before_action :set_membership_group, only: [:show, :edit, :update, :destroy, :assign_memberships, :update_memberships]

  def index
    @membership_groups = @tenant.membership_groups.order(:position, :created_at)
  end

  def show
  end

  def new
    @membership_group = @tenant.membership_groups.build
  end

  def edit
  end

  def create
    @membership_group = @tenant.membership_groups.build(membership_group_params)

    if @membership_group.save
      redirect_to ruler_area_tenant_memberships_group_path(@tenant, @membership_group), notice: 'メンバーシップグループを作成しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @membership_group.update(membership_group_params)
      redirect_to ruler_area_tenant_memberships_group_path(@tenant, @membership_group), notice: 'メンバーシップグループを更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @membership_group.destroy
    redirect_to ruler_area_tenant_memberships_groups_path(@tenant), notice: 'メンバーシップグループを削除しました。'
  end

  def assign_memberships
    @memberships = Membership.where(tenant_id: @tenant_id).order(:position, :created_at)
    @assigned_membership_ids = @membership_group.memberships.pluck(:id)
  end

  def update_memberships
    ActiveRecord::Base.transaction do
      # 指定されたメンバーシップをこのグループに紐づける
      if params[:membership_ids].present?
        Membership.where(id: params[:membership_ids], tenant_id: @tenant_id).update_all(membership_group_id: @membership_group.id)
      end

      # 現在このグループに紐づけられているメンバーシップのうち、id指定がなかったものをグループから外す
      @membership_group.memberships.where.not(id: params[:membership_ids]).update_all(membership_group_id: nil)
    end

    redirect_to ruler_area_tenant_memberships_group_path(@tenant, @membership_group), notice: 'メンバーシップの紐づけを更新しました。'
  end

  private

  def set_membership_group
    @membership_group = @tenant.membership_groups.find(params[:id])
  end

  def membership_group_params
    params.require(:memberships_group).permit(:name, :display_name, :position)
  end
end
