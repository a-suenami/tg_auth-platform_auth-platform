module API::V1::Authentication
  class ProfilesController < ApplicationController
    before_action :registrations_session_authenticate

    def create
      if Users::UpdateService.new(user_params).execute(user: @user)
        if @user.password_digest.present?
          @user.set_enabled
        end

        if session[:auth_url].present?
          # TODO: レスポンスをしっかり定義する
          render json: { status: 'ok', redirect_url: session[:auth_url] }
        else
          handle_400 error_details: ['failed load auth url']
        end
      else
        handle_400 error_details: ['failed to create profiles']
      end
    end

    private

    def registrations_session_authenticate
      raise handle_401 error_details: ['session not set'] if session[:registering_user_id].blank?

      @user = User.find session[:registering_user_id]
    end

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
