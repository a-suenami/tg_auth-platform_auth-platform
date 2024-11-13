module ShopifyArea
  class MultipassController < ApplicationController
    def auth
      session[:return_to] = params[:return_to] if params[:return_to]
      raise ActiveRecord::RecordNotFound if Tenant.current.shopify_record_multipass_setting.blank?

      authorization_endpoint_url = build_authorization_endpoint_url(sign_up: false)

      redirect_to authorization_endpoint_url, allow_other_host: true
    end

    def register
      session[:return_to] = params[:return_to] if params[:return_to]
      raise ActiveRecord::RecordNotFound if Tenant.current.shopify_record_multipass_setting.blank?

      authorization_endpoint_url = build_authorization_endpoint_url(sign_up: true)

      redirect_to authorization_endpoint_url, allow_other_host: true
    end

    def callback
      raise ActiveRecord::RecordNotFound if Tenant.current.shopify_record_multipass_setting.blank?

      # codeを検証
      oauth_access_grant = Authentication::OauthAccessGrants::VerifyService.new.execute!(token: params[:code], oauth_client_id: Tenant.current.shopify_record_multipass_setting.oauth_client_id,
code_verifier: session[:shopify_multipass_code_verifier],)

      # code無効の場合はエラー表示
      # 悪意あるリクエスト以外はありえないケース
      return render :error if oauth_access_grant.nil?

      return_to = session[:return_to]
      session[:return_to] = nil

      redirect_to generate_multipass(return_to, oauth_access_grant.resource_owner), allow_other_host: true
    end

    private

    def build_authorization_endpoint_url(sign_up: false)
      code_verifier, authorization_endpoint_url = AppShopifyMultipass::CreateAuthorizationEndpointUrlService.new.execute(
        shopify_record_multipass_setting: Tenant.current.shopify_record_multipass_setting, oauth_authorization_path:, redirect_uri: shopify_area_multipass_auth_callback_url, sign_up:,
      )

      session[:shopify_multipass_code_verifier] = code_verifier

      authorization_endpoint_url
    end

    def generate_multipass(return_to, user)
      AppIdp::Multipass.new.generate(Tenant.current.shopify_record_multipass_setting, user, return_to, request.remote_ip)
    end

    def login_spa_application
      # login_spa_applicationない場合は強制エラー
      @login_spa_application ||= Tenant.current.login_spa_application || raise(ActiveRecord::RecordNotFound)
    end
  end
end
