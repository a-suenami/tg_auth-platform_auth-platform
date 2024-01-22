module API::V1::Authentication
  class PasswordsController < ApplicationController
    include CookieAuthable
    skip_before_action :session_authenticate, only: [:create]
    before_action :registrations_session_authenticate, only: [:create]

    def create
      raise Exceptions::Authentication::PasswordAlreadySet if @current_user.password_digest.present?

      @current_user.update!(password_params)
      cookie_session[:registering_user_id] = nil
      cookie_session[:current_user_id] = @current_user.id
      head :no_content
    end

    def update
      @current_user.update!(password_params)
      head :no_content
    end

    private

    def registrations_session_authenticate
      raise Exceptions::Auth::AuthError if cookie_session[:registering_user_id].blank?

      @current_user = User.active.find cookie_session[:registering_user_id]
    end

    def password_params
      params.require(:user).permit(:password)
    end
  end
end
