# frozen_string_literal: true

module TenantsArea::API
  class OauthController < ActionController::API

    def login
      client = OauthFirstPartyApplication.find_by!(uid: params[:client_id])

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

    def signup
    end

    def password_change
    end
  end
end
