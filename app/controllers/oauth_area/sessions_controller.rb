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

      base_url = case uri
      when URI::HTTP, URI::HTTPS
        # 与えられたURLからドメインとパスを抽出
        port = uri.port
        # デフォルトポート(HTTP: 80, HTTPS: 443)を除外する場合、ポートを表示しない
        port_string = (uri.scheme == 'http' && port == 80) || (uri.scheme == 'https' && port == 443) ? '' : ":#{port}"
        _base_url = "#{uri.scheme}://#{uri.host}#{port_string}"

        _base_url
      when URI::Generic
        # custom_url_scheme はそのまま通す
        url
      else
        # 原則こないが URL もし不正な場合は false を返す
        return false
      end

      # 抽出したURLがホワイトリストに含まれるかチェック
      allowed_logout_urls.any? do |whitelist_url|
        base_url.match?(/^#{Regexp.escape(whitelist_url)}/)
      end
    end
  end
end
