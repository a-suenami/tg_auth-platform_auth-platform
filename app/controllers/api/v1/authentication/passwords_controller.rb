module API::V1::Authentication
  class PasswordsController < ApplicationController
    before_action :registrations_session_authenticate

    def create
      return handle_400 error_details: ['already created passowrd'] if @user.password_digest.present?

      if @user.update(password_params)
        session[:current_user_id] = @user.id
        head :no_content
      else
        handle_400 error_details: ['failed to create password']
      end
    end

    private

    def registrations_session_authenticate
      return handle_401 error_details: ['session not set'] if session[:registering_user_id].blank?

      @user = User.find session[:registering_user_id]
    end

    def password_params
      params.require(:user).permit(:password)
    end
  end
end
