module OauthArea
  class AccountLocksController < ApplicationController
    # Account Lock解除 エンドポイント
    def unlock
      if params[:unlock_token].present?
        account_lock = AccountLock.find_by(unlock_token: params[:unlock_token])
        if account_lock.present?
          account_lock.reset_failed_attempts
          account_lock.save
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
