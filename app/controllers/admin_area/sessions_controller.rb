module AdminArea
  class SessionsController < ApplicationController
    skip_before_action :authenticate!, only: %i[new create]

    def new
      render :new
    end

    def create
      # authenticate admin
      admin = Admin.find_by(email: params[:email])
      if admin&.authenticate(params[:password])
        session[:current_admin_id] = admin.id

        redirect_to admin_area_users_path
      else
        # rubocop:disable Rails/I18nLocaleTexts
        redirect_to admin_area_login_path, alert: 'Invalid email or password'
        # rubocop:enable Rails/I18nLocaleTexts
      end
    end

    def destroy
      session[:current_admin_id] = nil
      redirect_to admin_area_login_path
    end
  end
end
