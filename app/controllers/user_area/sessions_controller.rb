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
        # TODO: session[:auth_url]がない場合、oauth_applicationsからredirect_uriにリダイレクトする
        redirect_to session[:auth_url]
      else
        # rubocop:disable Rails/I18nLocaleTexts
        flash[:error] = 'Invalid email or password'
        render 'user_area/sample/sessions/new'
        # rubocop:enable Rails/I18nLocaleTexts
      end
    end
  end
end
