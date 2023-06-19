module API::V1::Authentication
  class PasswordsController < ApplicationController
    include CookieAuthable
    skip_before_action :session_authenticate, only: [:create]
    before_action :registrations_session_authenticate, only: [:create]

    def create
      raise Exceptions::Services::Users::PasswordAlreadySet if @current_user.password_digest.present?

      @current_user.update!(password_params)
      session[:current_user_id] = @current_user.id
      head :no_content
    end

    def update
      @current_user.update!(password_params)
      head :no_content
    end

    private

    def registrations_session_authenticate
      raise Exceptions::Auth::AuthError if session[:registering_user_id].blank?

      @current_user = User.find session[:registering_user_id]
    end

    def password_params
      params.require(:user).permit(:password)
    end
  end
end
