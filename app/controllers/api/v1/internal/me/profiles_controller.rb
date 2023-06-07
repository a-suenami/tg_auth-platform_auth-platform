module API::V1::Internal
  class Me::ProfilesController < ApplicationController

    def show; end

    def create
      if Users::UpdateService.new(user_params).execute(user: @current_user)
        if @current_user.password_digest.present?
          @current_user.set_enabled
        end

        render :show
      else
        handle_400 error_details: ['failed to create profiles']
      end
    end

    # TODO: createと変わらないので、そもそも必要かどうか検討する
    def update
      if Users::UpdateService.new(user_params).execute(user: @current_user)
        if @current_user.password_digest.present?
          @current_user.set_enabled
        end

        render :show
      else
        handle_400 error_details: ['failed to create profiles']
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
