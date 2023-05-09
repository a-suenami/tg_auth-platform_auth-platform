module TenantsArea
  class ProfilesController < ApplicationController
    def new
      @user = User.find session[:registering_user_id]
      return redirect_to '/passwords/new' if @user.password_digest.blank?

      @user_profile = UserProfile.new(user_id: @user.id)
      render "tenants_area/#{Tenant.current.id}_area/profiles/new"
    end

    def create
      @user = User.find session[:registering_user_id]
      return redirect_to '/passwords/new' if @user.password_digest.blank?

      if @user.update(user_params)
        session[:registering_user_id] = nil
        session[:current_user_id] = @user.id

        if session[:auth_url].present?
          redirect_to session[:auth_url]
        else
          # TODO: redirect maypage
          render "tenants_area/#{Tenant.current.id}_area/sessions/error"
        end
      else
        render "tenants_area/#{Tenant.current.id}_area/profiles/new"
      end
    end

    private

    def user_params
      params.require(:user).permit(
        user_profile_attributes: [
          :first_name,
          :last_name,
          :first_name_kana,
          :last_name_kana,
          :birth_date,
          :gender,
        ],
        contact_address_attributes: [
          :zip_code,
          :prefecture_code,
          :city,
          :address_1,
          :address_2,
        ],
      )
    end
  end
end
