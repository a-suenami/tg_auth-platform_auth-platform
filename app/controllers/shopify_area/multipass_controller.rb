module ShopifyArea
  class MultipassController < ApplicationController
    before_action :store_params, only: %i[auth register]

    def auth
      authorization_endpoint_url = build_authorization_endpoint_url(sign_up: false)

      redirect_to authorization_endpoint_url, allow_other_host: true
    end

    def register
      authorization_endpoint_url = build_authorization_endpoint_url(sign_up: true)

      redirect_to authorization_endpoint_url, allow_other_host: true
    end

    def callback
      # codeを検証
      oauth_access_grant = Authentication::OauthAccessGrants::VerifyService.new.execute!(token: params[:code], oauth_client_id: current_multipass_store.oauth_client_id,
code_verifier: session[:shopify_multipass_code_verifier],)

      # code無効の場合はエラー表示
      # 悪意あるリクエスト以外はありえないケース
      return render :error if oauth_access_grant.nil?

      return_to = session[:return_to]
      session[:return_to] = nil

      redirect_to generate_multipass(return_to, oauth_access_grant.resource_owner), allow_other_host: true
    end

    private

    def store_params
      session[:return_to] = params[:return_to] if params[:return_to]
      session[:store_name] = params[:store_name] if params[:store_name]
    end

    def current_multipass_store
      raise ActiveRecord::RecordNotFound if session[:store_name].blank?

      @current_multipass_store ||= Tenant.current.shopify_record_multipass_stores.find_by!(store_name: session[:store_name])
    end

    def build_authorization_endpoint_url(sign_up: false)
      code_verifier, authorization_endpoint_url = AppShopifyMultipass::CreateAuthorizationEndpointUrlService.new.execute(
        shopify_record_multipass_store: current_multipass_store, oauth_authorization_path:, redirect_uri: shopify_area_multipass_auth_callback_url, sign_up:,
      )

      session[:shopify_multipass_code_verifier] = code_verifier

      authorization_endpoint_url
    end

    def generate_multipass(return_to, user)
      AppIdp::Multipass.new.generate(current_multipass_store, user, return_to, request.remote_ip)
    end

    def login_spa_application
      # login_spa_applicationない場合は強制エラー
      @login_spa_application ||= Tenant.current.login_spa_application || raise(ActiveRecord::RecordNotFound)
    end
  end
end
