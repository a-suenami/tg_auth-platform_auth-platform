module API::V1::Internal
  class Me::ProfilesController < ApplicationController

    def show; end

    def update
      Users::UpdateService.new(user_params).execute(user: @current_user)
      if @current_user.enabled == false
        @current_user.set_enabled_on_completion
        if @current_user.enabled == true
          Authentication::SendRegisteredEmailService.new.execute!(user: @current_user)
        end
      end

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
