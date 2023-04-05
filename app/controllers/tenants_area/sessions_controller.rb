module TenantsArea
  class SessionsController < ApplicationController
    def new
      # render by tenant
      render "tenants_area/#{Tenant.current.id}_area/sessions/new"
    end

    def create
      # authenticate user
      user = User.find_by(email: params[:email])
      if user&.authenticate(params[:password])
        # create session
        session[:current_user_id] = user.id

        if session[:auth_url].present?
          redirect_to session[:auth_url]
        else
          # session[:auth_url]がない場合は認証フローエラーとして処理する
          render "tenants_area/#{Tenant.current.id}_area/sessions/error"
        end
      else
        # rubocop:disable Rails/I18nLocaleTexts
        flash[:error] = 'Invalid email or password'
        render "tenants_area/#{Tenant.current.id}_area/sessions/new"
        # rubocop:enable Rails/I18nLocaleTexts
      end
    end
  end
end
