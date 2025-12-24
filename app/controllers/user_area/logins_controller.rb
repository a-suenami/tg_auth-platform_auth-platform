# typed: true
# frozen_string_literal: true

module UserArea
  class LoginsController < ApplicationController
    before_action :check_web_login_enabled
    before_action :redirect_if_logged_in, only: [:new]

    def new
      @email = params[:email]
    end

    def create
      user = Authentication::SessionCreateService.new.execute!(
        email: params[:email],
        password: params[:password]
      )

      cookie_session[:current_user_id] = user.id

      # SMS MFA が必要な場合はMFA画面へリダイレクト
      if sms_mfa_required?(user)
        redirect_to mfa_sms_path
      else
        redirect_after_login
      end
    rescue Exceptions::Auth::AuthError
      flash.now[:error] = 'メールアドレスまたはパスワードが正しくありません'
      @email = params[:email]
      render :new, status: :unprocessable_entity
    rescue Exceptions::Auth::AccountLocked
      flash.now[:error] = 'アカウントがロックされています。メールをご確認ください'
      @email = params[:email]
      render :new, status: :unprocessable_entity
    end

    private

    def check_web_login_enabled
      login_spa = Tenant.current&.login_spa_application
      return if login_spa&.enable_web_login

      render plain: 'Web login is not enabled', status: :forbidden
    end

    def redirect_if_logged_in
      return unless cookie_session[:current_user_id].present?

      user = User.active.find_by(id: cookie_session[:current_user_id])
      redirect_after_login if user.present?
    end

    def sms_mfa_required?(user)
      return false if user.suppress_sms_verification
      return false unless Tenant.current&.sms_verification_required
      return false unless user.sms_verified && user.phone_number.present?

      cookie_session[:sms_mfa_verified].blank?
    end

    def redirect_after_login
      if cookie_session[:auth_url].present?
        redirect_to cookie_session[:auth_url]
      else
        redirect_to mypage_path
      end
    end
  end
end
