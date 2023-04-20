# frozen_string_literal: true

module TenantsArea::API
  class OauthController < ActionController::API

    def login
      # TODO: check client id

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
      session[:current_user_id] = nil
      # TODO: validate returnTo. check whitelist
      redirect_to params[:returnTo]
    end

    def signup
    end

    def password_change
    end
  end
end
