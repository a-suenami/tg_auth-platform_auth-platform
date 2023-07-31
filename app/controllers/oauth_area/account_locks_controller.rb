module OauthArea
  class AccountLocksController < ApplicationController
    # Account Lock解除 エンドポイント
    def unlock
      if AccountLocks::UnlockByTokenService.new.execute(token: params[:unlock_token])
        @login_url = if session[:auth_url].present?
          Tenant.current.login_spa_application.login_url_with_flag
        end
        render 'unlock'
      else
        render 'oauth_area/sessions/error'
      end
    end
  end
end
