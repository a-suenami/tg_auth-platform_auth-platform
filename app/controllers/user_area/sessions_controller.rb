module UserArea
  class SessionsController < ApplicationController
    def new
      render 'user_area/sample/sessions/new'
    end

    def create
      # authenticate user
      user = User.find_by(email: params[:email])
      if user&.authenticate(params[:password])
        # create session
        session[:current_user_id] = user.id
        redirect_to oauth_authorization_path
      else
        flash[:error] = 'Invalid email or password'
        render 'user_area/sample/sessions/new'
      end
    end
  end
end
