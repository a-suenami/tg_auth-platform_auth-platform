# frozen_string_literal: true

module API::V1::Authentication
  class SessionsController < ApplicationController

    def create
      user = User.find_by(email: params[:email])
      if user&.authenticate(params[:password])
        # create session
        session[:current_user_id] = user.id

        render json: { status: 'ok' }
      else
        raise Exceptions::Auth::AuthError
      end
    end

    def logout
      session[:current_user_id] = nil

      render json: { status: 'ok' }
    end
  end
end
