module API::V1::Internal
  class Me::ProfilesController < ApplicationController

    def show; end

    def update
      Users::UpdateService.new(user_params).execute(user: @current_user)
      if @current_user.password_digest.present?
        @current_user.set_enabled
      end

      render :show
    end


    private

    def user_params
      params.require(:user).permit(
        :tel,
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
          :country_code,
        ],
      )
    end
  end
end
