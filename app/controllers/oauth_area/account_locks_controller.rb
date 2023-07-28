module OauthArea
  class AccountLocksController < ApplicationController
    # Account Lock解除 エンドポイント
    def unlock
      if params[:unlock_token].present?
        account_lock = AccountLock.find_by(unlock_token: params[:unlock_token])
        if account_lock.present?
          account_lock.reset_failed_attempts
          account_lock.save

          @login_url = if session[:auth_url].present?
            Tenant.current.login_spa_application.login_url_with_flag
          end
          render 'unlock'
        else
          render 'oauth_area/sessions/error'
        end
      else
        render 'oauth_area/sessions/error'
      end
    end
  end
end
