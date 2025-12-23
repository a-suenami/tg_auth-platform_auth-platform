# typed: true
# frozen_string_literal: true

module UserArea
  class SignUpsController < ApplicationController
    before_action :check_web_sign_up_enabled
    before_action :require_registering_user, only: %i[
      set_password set_password_submit
      phone_number phone_number_submit
      verify_sms verify_sms_submit
      resend_sms
    ]

    # Step 1: メールアドレス入力画面
    def new
      @email = params[:email]
    end

    # Step 1: メールアドレス送信
    def create
      @user = Authentication::SendVerificationEmailService.new.execute!(
        email: params[:email],
        captcha_score: nil
      )
      cookie_session[:registering_user_id] = @user.id
      redirect_to sign_up_verify_email_path
    rescue Exceptions::Authentication::InvalidEmail
      flash.now[:error] = '正しいメールアドレスを入力してください'
      @email = params[:email]
      render :new, status: :unprocessable_entity
    end

    # Step 2: メール検証コード入力画面
    def verify_email
      @user_id = cookie_session[:registering_user_id]
    end

    # Step 2: メール検証コード送信
    def verify_email_submit
      @user = Authentication::VerifyEmailService.new.execute!(
        email_verification_code: params[:email_verification_code],
        user_id: cookie_session[:registering_user_id]
      )
      redirect_to sign_up_set_password_path
    rescue Exceptions::Authentication::InvalidCode
      flash.now[:error] = '認証コードが正しくありません'
      @user_id = cookie_session[:registering_user_id]
      render :verify_email, status: :unprocessable_entity
    rescue Exceptions::Authentication::ExpiredEmailVerificationCode
      flash.now[:error] = '認証コードの有効期限が切れています'
      @user_id = cookie_session[:registering_user_id]
      render :verify_email, status: :unprocessable_entity
    rescue Exceptions::Authentication::EmailVerificationCodeAttemptsIsOver
      flash.now[:error] = '認証コードの入力回数が上限に達しました'
      @user_id = cookie_session[:registering_user_id]
      render :verify_email, status: :unprocessable_entity
    end

    # メール再送信
    def resend_email
      @user = Authentication::SendVerificationEmailService.new.execute!(
        email: registering_user.email,
        captcha_score: nil
      )
      flash[:notice] = '認証コードを再送信しました'
      redirect_to sign_up_verify_email_path
    end

    # Step 3: パスワード設定画面
    def set_password
      @user = registering_user
    end

    # Step 3: パスワード設定送信
    def set_password_submit
      user = registering_user
      user.password = params[:password]
      user.password_confirmation = params[:password_confirmation]
      user.enabled = true

      if user.save
        # SMS検証が必要な場合は Step 4 へ
        if sms_verification_required?
          redirect_to sign_up_phone_number_path
        else
          complete_registration(user)
        end
      else
        flash.now[:error] = user.errors.full_messages.join(', ')
        @user = user
        render :set_password, status: :unprocessable_entity
      end
    end

    # Step 4: 電話番号入力画面
    def phone_number
      @user = registering_user
    end

    # Step 4: 電話番号送信
    def phone_number_submit
      user = registering_user
      Authentication::SendVerificationSmsService.new.execute!(
        phone_number: params[:phone_number],
        user_id: user.id,
        ip_address: request.remote_ip,
        delivery_type: params[:delivery_type],
        verifier_type: :registration
      )
      cookie_session[:registering_phone_number] = params[:phone_number]
      redirect_to sign_up_verify_sms_path
    rescue Exceptions::Authentication::NoSmsSupportedCountry
      flash.now[:error] = 'この電話番号はSMS認証に対応していません'
      @user = registering_user
      render :phone_number, status: :unprocessable_entity
    rescue Exceptions::Authentication::SmsSendLimit
      flash.now[:error] = 'SMS送信の上限に達しました。しばらく経ってからお試しください'
      @user = registering_user
      render :phone_number, status: :unprocessable_entity
    end

    # SMS再送信
    def resend_sms
      user = registering_user
      phone_number = cookie_session[:registering_phone_number]
      Authentication::SendVerificationSmsService.new.execute!(
        phone_number: phone_number,
        user_id: user.id,
        ip_address: request.remote_ip,
        delivery_type: params[:delivery_type],
        verifier_type: :registration
      )
      flash[:notice] = '認証コードを再送信しました'
      redirect_to sign_up_verify_sms_path
    rescue Exceptions::Authentication::SmsSendLimit
      flash[:error] = 'SMS送信の上限に達しました。しばらく経ってからお試しください'
      redirect_to sign_up_verify_sms_path
    end

    # Step 5: SMS検証コード入力画面
    def verify_sms
      @phone_number = cookie_session[:registering_phone_number]
    end

    # Step 5: SMS検証コード送信
    def verify_sms_submit
      user = Authentication::VerifySmsService.new.execute!(
        verification_code: params[:verification_code],
        user_id: registering_user.id,
        verifier_type: :registration
      )
      complete_registration(user)
    rescue Exceptions::Authentication::InvalidCode
      flash.now[:error] = '認証コードが正しくありません'
      @phone_number = cookie_session[:registering_phone_number]
      render :verify_sms, status: :unprocessable_entity
    rescue Exceptions::Authentication::ExpiredSmsVerificationCode
      flash.now[:error] = '認証コードの有効期限が切れています'
      @phone_number = cookie_session[:registering_phone_number]
      render :verify_sms, status: :unprocessable_entity
    rescue Exceptions::Authentication::SmsVerificationCodeAttemptsIsOver
      flash.now[:error] = '認証コードの入力回数が上限に達しました'
      @phone_number = cookie_session[:registering_phone_number]
      render :verify_sms, status: :unprocessable_entity
    rescue Exceptions::Authentication::SmsVerificationCodeUsed
      flash.now[:error] = '認証コードは既に使用されています'
      @phone_number = cookie_session[:registering_phone_number]
      render :verify_sms, status: :unprocessable_entity
    end

    private

    def check_web_sign_up_enabled
      login_spa = Tenant.current&.login_spa_application
      return if login_spa&.enable_web_sign_up

      render plain: 'Web sign up is not enabled', status: :forbidden
    end

    def require_registering_user
      return if cookie_session[:registering_user_id].present?

      redirect_to sign_up_path
    end

    def registering_user
      @registering_user ||= User.active.find(cookie_session[:registering_user_id])
    end

    def sms_verification_required?
      Tenant.current&.sms_verification_required
    end

    def complete_registration(user)
      # セッション情報をクリア
      cookie_session.delete(:registering_user_id)
      cookie_session.delete(:registering_phone_number)

      # ログイン状態にする
      cookie_session[:current_user_id] = user.id

      # SMS MFA が有効な場合は mfa_verified も設定
      cookie_session[:sms_mfa_verified] = Time.zone.now if user.sms_verified

      redirect_after_registration
    end

    def redirect_after_registration
      if cookie_session[:auth_url].present?
        redirect_to cookie_session[:auth_url]
      else
        redirect_to root_path
      end
    end
  end
end
