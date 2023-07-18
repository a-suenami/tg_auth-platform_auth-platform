module API::V1::Authentication
  class PasswordResetsController < ApplicationController
    # Httpリクエストのrequestと名前被り回避のため、冗長な名前に
    def reset_requests
      client = Tenant.current.login_spa_application
      if client.present?
        Users::SendPasswordResetEmailService.new.execute!(email: params[:email], base_url: client.redirect_url_on_password_reset)
      else
        raise ActiveRecord::RecordNotFound
      end
      head :no_content
    end

    def create
      user = Users::PasswordResetService.new(password_params).execute!(password_reset_code: params[:password_reset_code], email: params[:email])
      session[:current_user_id] = user.id
      head :no_content
    rescue ActiveRecord::RecordInvalid
      handle_400 error_details: ['validation error']
    end

    private

    def password_params
      params.permit(:password)
    end
  end
end
