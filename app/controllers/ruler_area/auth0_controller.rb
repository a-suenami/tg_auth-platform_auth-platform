# ./app/controllers/auth0_controller.rb

module RulerArea
  class Auth0Controller < ApplicationController
    skip_before_action :authenticate!, only: [:login, :callback, :failure]

    def login
      redirect_to ruler_area_root_path if signed_in?
    end

    def callback
      ruler ||= Ruler.find_by!(uid: request.env['omniauth.auth'].uid)

      if ruler.present?
        session[:current_ruler_id] = ruler.id
        redirect_to ruler_area_root_path, notice: 'ログインしました。' # rubocop:disable Rails/I18nLocaleTexts
      else
        logout
        flash.now[:error] = 'ログインに失敗しました'
        flash.keep
      end
    end

    def failure
      # Handles failed authentication -- Show a failure page (you can also handle with a redirect)
      @error_msg = request.params['message']
    end

    def logout
      reset_session
      redirect_to logout_url, allow_other_host: true
    end

    private

    def logout_url
      request_params = {
        returnTo: ruler_area_login_path,
        client_id: Settings.ruler.auth0.auth0_client_id,
      }

      URI::HTTPS.build(host: Settings.ruler.auth0.auth0_domain, path: '/v2/logout', query: request_params.to_query).to_s
    end
  end
end
