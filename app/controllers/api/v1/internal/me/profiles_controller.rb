module API::V1::Internal
  class Me::ProfilesController < ApplicationController

    def show; end

    def update
      Users::UpdateService.new(user_params).execute(user: @current_user)
      @current_user.set_enabled_on_completion

      render :show
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
          :street,
          :building,
          :phone_number,
          :country_code,
        ],
      )
    end
  end
end
