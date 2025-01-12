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
        error_params = { messages: form.errors.as_json(full_messages: true), details: form.errors.details }

        invalid_request_error(
          code: :validation_error,
          message: form.errors.full_messages.join(', '),
          params: error_params,
        )
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
