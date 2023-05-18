module API::V1::Authentication
  class PasswordResetsController < ApplicationController
    def create
      client = Tenant.current.login_spa_application
      if client.present?
        Users::SendPasswordResetEmailService.new.execute!(email: params[:email], base_url: client.redirect_url_on_password_reset)
      else
        Users::SendPasswordResetEmailService.new.execute!(email: params[:email], base_url: "#{request.protocol}#{request.host_with_port}/password_resets/edit")
      end
      render json: { status: 'ok' }
    end

    def update
      Users::PasswordResetService.new(update_password_params).execute!(password_reset_code: params[:password_reset_code], email: params[:email])
      render json: { status: 'ok' }
    end

    private

    def update_password_params
      params.permit(:password, :password_confirmation)
    end
  end
end
