# frozen_string_literal: true

module API::V1::Authentication
  class SessionsController < ApplicationController

    def create
      user = Authentication::SessionCreateService.new.execute!(email: params[:email], password: params[:password])
      cookie_session[:current_user_id] = user.id

      require_sms_two_factor_authentication = check_require_sms_two_factor_authentication

      render :create, locals: { user:, require_sms_two_factor_authentication: }
    end

    private

    def check_require_sms_two_factor_authentication
      return false if cookie_session[:auth_url].blank?

      _, query = cookie_session[:auth_url].split('?', 2)
      # CGI.parseを使用してクエリパラメータをハッシュとして解析
      query_params = CGI.parse(query)
      # 'client_id'キーでクエリパラメータから値を取得
      client_id = query_params['client_id'].first

      return false if client_id.blank?

      client = OauthApplication.find_by(uid: client_id)
      return false if client.blank?

      client.require_two_factor_auth_by_sms
    end
  end
end
