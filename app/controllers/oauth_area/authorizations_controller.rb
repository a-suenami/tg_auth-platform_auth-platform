# typed: true

module OauthArea
  class AuthorizationsController < ApplicationController
    def relaunch
      if cookie_session[:auth_url].present?
        redirect_to cookie_session[:auth_url]
      else
        # 基本ここに入ることはないはず
        render 'oauth_area/sessions/error'
      end
    end
  end
end
