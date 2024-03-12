module OauthArea
  class SessionsController < ApplicationController
    def logout
      cookie_session.session_clear

      if params[:client_id] && params[:returnTo].present?
        oauth_application = Tenant.current.oauth_applications.find_by(uid: params[:client_id])
        if oauth_application&.allowed_logout_urls.present? && url_in_whitelist?(params[:returnTo], oauth_application)
          return redirect_to params[:returnTo], allow_other_host: true
        end
      end
      render :logout
    end

    private

    def url_in_whitelist?(url, oauth_application)
      allowed_logout_urls = oauth_application.allowed_logout_urls.split(/\R/)

      uri = URI.parse(url)
      # URLが不正な場合はfalseを返す
      return false unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

      # 与えられたURLからドメインとパスを抽出
      uri.query = nil
      base_url = uri.to_s
      base_url.chomp!('/') # 末尾のスラッシュを削除

      # 抽出したURLがホワイトリストに含まれるかチェック
      allowed_logout_urls.any? do |whitelist_url|
        whitelist_url.chomp!('/') # 末尾のスラッシュを削除
        base_url == whitelist_url
      end
    end
  end
end
