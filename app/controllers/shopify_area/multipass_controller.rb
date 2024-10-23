module ShopifyArea
  class MultipassController < ApplicationController
    def auth
      # 戻り先を記録
      session[:return_to] = params[:return_to] if params[:return_to]
      raise ActiveRecord::RecordNotFound if Tenant.current.shopify_record_multipass_setting.blank?

      code_verifier, authorization_endpoint_url = AppShopifyMultipass::CreateAuthorizationEndpointUrlService.new.execute(
        shopify_record_multipass_setting: Tenant.current.shopify_record_multipass_setting, oauth_authorization_path:, redirect_uri: shopify_area_multipass_auth_callback_url,
      )

      session[:shopify_multipass_code_verifier] = code_verifier

      # ログイン画面へ
      redirect_to authorization_endpoint_url, allow_other_host: true
    end

    def register
      # 戻り先を記録
      session[:return_to] = params[:return_to] if params[:return_to]

      # 新規登録画面へ
      # TODO: fix
      redirect_to oauth_register_url, allow_other_host: true
    end

    # TODO: fix
    def callback
      @code = params[:code]

      # codeを検証 & 失効
      oauth_access_grant = OauthAccessGrant.find_by(token: @code)
      if oauth_access_grant.blank? || !oauth_access_grant.accessible? || oauth_access_grant.code_challenge != Base64.urlsafe_encode64(
        OpenSSL::Digest::SHA256.digest(session[:shopify_multipass_code_verifier]), padding: false,
      )
        # 失効している場合は進行不可 codeの有効期限が切れている場合と、一度使用されたcodeの場合
        # 進行不可能なので、return_toに戻す
        return_to = session[:return_to]
        if return_to.present?
          return redirect_to return_to
        else
          # TODO: set error page
          raise Exceptions::Shopify::TokenInvalidError
        end
      else
        # codeを失効させる
        oauth_access_grant.revoke(Time.zone)
      end

      user = oauth_access_grant.resource_owner

      return_to = session[:return_to]
      session[:return_to] = nil

      redirect_to generate_multipass(return_to, user), allow_other_host: true
    end

    private

    def generate_multipass(return_to, user)
      AppIdp::Multipass.new.generate(Tenant.current.shopify_record_multipass_setting, user, return_to, request.remote_ip)
    end

    def login_spa_application
      # login_spa_applicationない場合は強制エラー
      @login_spa_application ||= Tenant.current.login_spa_application || raise(ActiveRecord::RecordNotFound)
    end
  end
end
