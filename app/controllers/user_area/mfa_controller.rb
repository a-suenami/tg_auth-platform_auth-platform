# typed: true
# frozen_string_literal: true

module UserArea
  class MFAController < ApplicationController
    before_action :require_login
    before_action :require_sms_mfa_enabled

    # SMS MFA 認証コード入力画面
    def new
      # SMS送信を自動的に行う
      unless flash[:sms_sent]
        send_mfa_sms
        flash.now[:notice] = '認証コードを送信しました'
      end
      @phone_number = current_user.phone_number
    end

    # SMS MFA 認証コード検証
    def create
      if current_user.suppress_sms_verification
        # マニュアル対応のユーザはスキップ
        cookie_session[:sms_mfa_verified] = Time.zone.now
        redirect_after_mfa
        return
      end

      Authentication::VerifySmsService.new.execute!(
        verification_code: params[:code],
        user_id: current_user.id,
        verifier_type: :mfa
      )
      cookie_session[:sms_mfa_verified] = Time.zone.now
      redirect_after_mfa
    rescue Exceptions::Authentication::InvalidCode
      flash.now[:error] = '認証コードが正しくありません'
      @phone_number = current_user.phone_number
      render :new, status: :unprocessable_entity
    rescue Exceptions::Authentication::ExpiredSmsVerificationCode
      flash.now[:error] = '認証コードの有効期限が切れています'
      @phone_number = current_user.phone_number
      render :new, status: :unprocessable_entity
    rescue Exceptions::Authentication::SmsVerificationCodeAttemptsIsOver
      flash.now[:error] = '認証コードの入力回数が上限に達しました'
      @phone_number = current_user.phone_number
      render :new, status: :unprocessable_entity
    rescue Exceptions::Authentication::SmsVerificationCodeUsed
      flash.now[:error] = '認証コードは既に使用されています'
      @phone_number = current_user.phone_number
      render :new, status: :unprocessable_entity
    end

    # SMS 再送信
    def resend
      send_mfa_sms
      flash[:notice] = '認証コードを再送信しました'
      flash[:sms_sent] = true
      redirect_to mfa_sms_path
    rescue Exceptions::Authentication::SmsSendLimit
      flash[:error] = 'SMS送信の上限に達しました。しばらく経ってからお試しください'
      redirect_to mfa_sms_path
    end

    private

    def require_login
      return if cookie_session[:current_user_id].present?

      redirect_to login_path
    end

    def require_sms_mfa_enabled
      return if Tenant.current&.sms_verification_required

      redirect_after_mfa
    end

    def current_user
      @current_user ||= User.active.find(cookie_session[:current_user_id])
    end

    def send_mfa_sms
      return if current_user.suppress_sms_verification

      Authentication::SendVerificationSmsService.new.execute!(
        phone_number: current_user.phone_number,
        user_id: current_user.id,
        ip_address: request.remote_ip,
        delivery_type: params[:delivery_type],
        verifier_type: :mfa
      )
    end

    def redirect_after_mfa
      if cookie_session[:auth_url].present?
        redirect_to cookie_session[:auth_url]
      else
        redirect_to mypage_path
      end
    end
  end
end
