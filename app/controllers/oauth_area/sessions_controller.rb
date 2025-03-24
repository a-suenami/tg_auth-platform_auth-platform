# typed: true

module OauthArea
  class SessionsController < ApplicationController
    def logout
      cookie_session.session_clear

      if params[:client_id] && params[:returnTo].present?
        oauth_application = T.must(Tenant.current).oauth_applications.find_by(uid: params[:client_id])
        if oauth_application&.allowed_logout_urls.present? && url_in_whitelist?(params[:returnTo], T.must(oauth_application))
          return redirect_to params[:returnTo], allow_other_host: true
        end
      end
      render :logout
    end

    private

    sig { params(url: String, oauth_application: OauthApplication).returns(T::Boolean) }
    def url_in_whitelist?(url, oauth_application)
      return false if url.blank? || oauth_application.allowed_logout_urls.blank?

      allowed_logout_urls = T.must(oauth_application.allowed_logout_urls).split(/\R/)

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
      end

      # 抽出したURLがホワイトリストに含まれるかチェック
      allowed_logout_urls.any? do |whitelist_url|
        base_url.match?(/^#{Regexp.escape(whitelist_url)}/)
      end
    end
  end
end
