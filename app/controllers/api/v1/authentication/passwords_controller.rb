module API::V1::Authentication
  class PasswordsController < ApplicationController
    include SessionKeyUseable
    before_action :session_key_authenticate

    def create
      @user = User.find params[:user_id]
      return handle_400 error_details: ['already created passowrd'] if @user.password_digest.present?

      if @user.update(password_params)
        # TODO: レスポンスをしっかり定義する
        render json: { status: 'ok' }
      else
        handle_400 error_details: ['failed to create password']
      end
    end

    private

    def password_params
      params.require(:user).permit(:password, :password_confirmation)
    end
  end
end
