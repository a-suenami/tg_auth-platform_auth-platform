module AdminArea
  class UserProfilesController < AdminArea::ApplicationController
    def new
      @user = User.find(params[:user_id])
      if @user.user_profile.present?
        redirect_to admin_area_user_path(@user), notice: t('helpers.messages.already_registered')
        return
      end
      @user_profile = @user.build_user_profile
    end

    def edit
      @user = User.find(params[:user_id])
      if @user.user_profile.blank?
        redirect_to admin_area_user_path(@user), notice: t('helpers.messages.not_registered')
        return
      end
      @user_profile = @user.user_profile
    end

    def create
      @user = User.find(params[:user_id])
      @user_profile = @user.build_user_profile(user_profile_params)
      if @user_profile.save
        redirect_to admin_area_user_path(@user), notice: t('helpers.messages.updated')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @user = User.find(params[:user_id])
      @user_profile = @user.user_profile
      if @user_profile.update(user_profile_params)
        redirect_to admin_area_user_path(@user), notice: t('helpers.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def user_profile_params
      params.require(:user_profile).permit(
        :first_name,
        :last_name,
        :first_name_kana,
        :last_name_kana,
        :birth_date,
        :gender,
      )
    end
  end
end
