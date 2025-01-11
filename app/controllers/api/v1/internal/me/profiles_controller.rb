module API::V1::Internal
  class Me::ProfilesController < ApplicationController

    def show; end

    def update
      form = UserForm.build(id: @current_user.id, params:)
      if form.valid?
        form.perform!
        # reloadしないとenabledの更新が反映されない
        @current_user.reload
        render :show
      else
        # TODO: error handling
        errors = {
          type: 'validation_error',
          code: 'invalid_params',
          message: form.errors.full_messages.join(', '),
        }
        render json: { errors: }, status: :bad_request
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
          :street,
          :building,
          :phone_number,
          :country_code,
        ],
      )
    end
  end
end
