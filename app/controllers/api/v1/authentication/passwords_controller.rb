module API::V1::Authentication
  class PasswordsController < ApplicationController
    include CookieAuthable
    skip_before_action :session_authenticate, only: [:create]
    before_action :registrations_session_authenticate, only: [:create]

    def create
      return handle_400 error_details: ['already created passowrd'] if @current_user.password_digest.present?

      begin
        @current_user.update!(password_params)
        session[:current_user_id] = @current_user.id
        head :no_content
      rescue ActiveRecord::RecordInvalid
        handle_400 error_details: ['validation error']
      rescue
        handle_400 error_details: ['failed to create password']
      end
    end

    def update
      begin @current_user.update!(password_params)
        head :no_content
      rescue ActiveRecord::RecordInvalid
        handle_400 error_details: ['validation error']
      rescue
        handle_400 error_details: ['failed to create password']
      end
    end

    private

    def registrations_session_authenticate
      return handle_401 error_details: ['session not set'] if session[:registering_user_id].blank?

      @current_user = User.find session[:registering_user_id]
    end

    def password_params
      params.require(:user).permit(:password)
    end
  end
end
