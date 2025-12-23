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

      contract = Membership::Contracts::CreateService.new.execute(
        user: current_user,
        membership_plan: @membership_plan,
        payment_method: payment_method,
        store: params[:store]
      )

      flash[:notice] = 'メンバーシップを購入しました'
      redirect_to my_memberships_path
    rescue Exceptions::Payment::CardMissing
      flash[:error] = 'クレジットカードが登録されていません'
      redirect_to membership_plan_path(@membership_plan)
    rescue Exceptions::Payment::PaymentMethodNotAvailable
      flash[:error] = '選択された支払い方法は利用できません'
      redirect_to membership_plan_path(@membership_plan)
    rescue Exceptions::Payment::AlreadySubscribed
      flash[:error] = '既にこのプランに加入しています'
      redirect_to my_memberships_path
    rescue StandardError => e
      Rails.logger.error("Membership purchase error: #{e.message}")
      flash[:error] = '購入処理中にエラーが発生しました'
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
