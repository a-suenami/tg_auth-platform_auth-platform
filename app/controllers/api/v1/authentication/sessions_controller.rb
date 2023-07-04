# frozen_string_literal: true

module API::V1::Authentication
  class SessionsController < ApplicationController

    def create
      user = User.find_by(email: params[:email])
      if user&.authenticate(params[:password])
        # create session
        session[:current_user_id] = user.id

        render :create, locals: { user: }
      else
        raise Exceptions::Auth::AuthError
      end
    end
  end
end
