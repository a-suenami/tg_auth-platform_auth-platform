# typed: true
# frozen_string_literal: true

module UserArea
  class CreditCardsController < ApplicationController
    before_action :require_login
    before_action :ensure_stripe_available

    # 登録済みカード情報表示
    def show
      @card = current_user.valid_stripe_card_payment_method
    end

    # カード登録画面
    def new
      @return_to = params[:return_to]
      @stripe_publishable_key = tenant_stripe_account.api_key.publishable_key
      @stripe_account_id = tenant_stripe_account.stripe_account_id_if_needed

      # SetupIntent を作成
      customer_result = ensure_stripe_customer!
      if customer_result.is_a?(Mangrove::Result::Err)
        Rails.logger.error "[CreditCards] Customer creation error: #{customer_result.err_inner.inspect}"
        flash[:error] = "Stripe顧客の作成中にエラーが発生しました: #{customer_result.err_inner.message}"
        redirect_to return_path
        return
      end

      result = StripeRecord::SetupIntent.api_create_card_setup_intent(
        tenant_stripe_account: tenant_stripe_account,
        user: current_user,
      )

      if result.is_a?(Mangrove::Result::Err)
        Rails.logger.error "[CreditCards] SetupIntent creation error: #{result.err_inner.inspect}"
        flash[:error] = "カード登録の準備中にエラーが発生しました: #{result.err_inner.message}"
        redirect_to return_path
        return
      end

      @setup_intent = result.ok_inner
    end

    # カード登録完了処理
    def complete
      setup_intent_id = params.require(:setup_intent_id)
      setup_intent = current_user.stripe_setup_intents.find_by!(remote_id: setup_intent_id)

      result = setup_intent.create_card_payment_method

      case result
      when StripeRecord::SetupIntent::CreateCardPaymentMethodResult::Succeeded
        flash[:notice] = I18n.t('user_area.credit_cards.registered')
      when StripeRecord::SetupIntent::CreateCardPaymentMethodResult::AlreadyCreated
        flash[:notice] = I18n.t('user_area.credit_cards.already_registered')
      when StripeRecord::SetupIntent::CreateCardPaymentMethodResult::InvalidStatus
        flash[:error] = I18n.t('user_area.credit_cards.registration_incomplete')
      when StripeRecord::SetupIntent::CreateCardPaymentMethodResult::InvalidPaymentMethodType
        flash[:error] = I18n.t('user_area.credit_cards.not_card')
      when StripeRecord::SetupIntent::CreateCardPaymentMethodResult::StripeError
        flash[:error] = I18n.t('user_area.credit_cards.registration_error')
      end

      redirect_to return_path
    end


    # カード削除
    def destroy
      result = current_user.detach_stripe_payment_methods
      if result.is_a?(Mangrove::Result::Err)
        flash[:error] = I18n.t('user_area.credit_cards.delete_error')
      else
        flash[:notice] = I18n.t('user_area.credit_cards.deleted')
      end
      redirect_to mypage_path
    end

    private

    def require_login
      return if cookie_session[:current_user_id].present?

      redirect_to login_path
    end

    def current_user
      @current_user ||= User.find(cookie_session[:current_user_id])
    end

    def tenant_stripe_account
      @tenant_stripe_account ||= T.must(Tenant.current!.tenant_stripe_account)
    end

    def ensure_stripe_available
      tenant = Tenant.current!
      Rails.logger.info "[CreditCards] Tenant.current: id=#{tenant.id}, domain=#{tenant.domain}"
      tenant_stripe = tenant.tenant_stripe_account
      Rails.logger.info "[CreditCards] tenant_stripe_account: #{tenant_stripe.inspect}"
      return if tenant_stripe.present?

      flash[:error] = I18n.t('user_area.credit_cards.not_available')
      redirect_to mypage_path
    end

    def ensure_stripe_customer!
      return Mangrove::Result.ok(true) if current_user.payment_customer_id.present?

      current_user.create_stripe_customer(tenant_stripe_account: tenant_stripe_account)
    end

    def return_path
      return params[:return_to] if params[:return_to].present? && params[:return_to].start_with?('/')

      mypage_path
    end
  end
end
