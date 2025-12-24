# typed: true
# frozen_string_literal: true

module UserArea
  class MembershipsController < ApplicationController
    before_action :require_login
    before_action :set_membership_plan, only: %i[show purchase]

    # メンバーシッププラン一覧
    def index
      @memberships = Membership.includes(:membership_group, membership_plans: :plan_payment_methods)
                               .order(:position)
      @membership_plans = Membership::Plan.includes(:plan_payment_methods, :plan_components, plan_components: :membership)
                                          .joins(:plan_components)
                                          .active
                                          .distinct
                                          .order(:amount)
    end

    # プラン詳細・購入画面
    def show
      @user = current_user
      @has_card = current_user.valid_stripe_card_payment_method.present?
    end

    # 購入処理
    def purchase
      payment_method = params[:payment_method] || 'credit_card'

      Membership::Contracts::CreateService.new.execute(
        user: current_user,
        membership_plan: @membership_plan,
        payment_method: payment_method,
        store: params[:store],
      )

      flash[:notice] = I18n.t('user_area.memberships.purchased')
      redirect_to my_memberships_path
    rescue Exceptions::Payment::CardMissing
      flash[:error] = I18n.t('user_area.memberships.card_missing')
      redirect_to membership_plan_path(@membership_plan)
    rescue Exceptions::Payment::PaymentMethodNotAvailable
      flash[:error] = I18n.t('user_area.memberships.payment_method_not_available')
      redirect_to membership_plan_path(@membership_plan)
    rescue Exceptions::Payment::AlreadyHaveMembership
      flash[:error] = I18n.t('user_area.memberships.already_subscribed')
      redirect_to my_memberships_path
    rescue StandardError => e
      Rails.logger.error("Membership purchase error: #{e.message}")
      flash[:error] = I18n.t('user_area.memberships.purchase_error')
      redirect_to membership_plan_path(@membership_plan)
    end

    # 契約中のメンバーシップ一覧
    def my_memberships
      @contracts = current_user.membership_contracts
                               .includes(current_contract_term: :membership_plan)
                               .order(created_at: :desc)
    end

    private

    def require_login
      return if cookie_session[:current_user_id].present?

      redirect_to login_path
    end

    def current_user
      @current_user ||= User.find(cookie_session[:current_user_id])
    end

    def set_membership_plan
      @membership_plan = Membership::Plan.includes(:plan_payment_methods, :plan_components, plan_components: :membership)
                                         .active
                                         .find(params[:id])
    end
  end
end
