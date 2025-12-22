# typed: true

# ./app/controllers/auth0_controller.rb

module AdminArea
  class Auth0Controller < ApplicationController
    layout :resolve_auth0_layout
    skip_before_action :authenticate!, only: [:login, :callback, :failure]

    def login
      redirect_to admin_area_users_path if signed_in?
      render_with_ui_toggle(:login) unless performed?
    end

    def callback
      admin ||= Admin.find_by(uid: request.env['omniauth.auth'].uid)

      if admin.present?
        session[:current_admin_id] = admin.id
        redirect_to admin_area_users_path, notice: 'ログインしました。'
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

    def resolve_auth0_layout
      new_ui_enabled? ? 'admin_area/auth0_v202601' : 'admin_area/auth0'
    end

    def logout_url
      request_params = {
        returnTo: admin_area_login_url,
        client_id: Settings.admin.auth0.auth0_client_id,
      }

      URI::HTTPS.build(host: Settings.admin.auth0.auth0_domain, path: '/v2/logout', query: request_params.to_query).to_s
    end
  end
end
