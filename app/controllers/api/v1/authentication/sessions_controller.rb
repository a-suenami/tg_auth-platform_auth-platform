# frozen_string_literal: true

module API::V1::Authentication
  class SessionsController < ApplicationController

    def create
      # clientが存在するかチェック
      OauthFirstPartyApplication.find_by!(uid: params[:client_id])

      user = User.find_by(email: params[:email])
      if user&.authenticate(params[:password])
        # create session
        session[:current_user_id] = user.id

        render json: { status: 'ok' }
      else
        render json: { status: 'error' }
      end
    end

    def logout
      client = OauthFirstPartyApplication.find_by(uid: params[:client_id])

      if client.present? && client.vaild_return_to?(params[:returnTo])
        session[:current_user_id] = nil
        redirect_to params[:returnTo], allow_other_host: true
      else
        render :error, formats: :html
      end
    end
  end
end
