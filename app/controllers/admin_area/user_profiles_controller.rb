# typed: true

module AdminArea
  class UserProfilesController < AdminArea::ApplicationController
    def new
      @user = User.find(params[:user_id])
      if @user.user_profile.present?
        redirect_to admin_area_user_path(@user), notice: t('helpers.messages.already_registered')
        return
      end
      @user_profile = Admins::UserProfileForm.build(user_id: params[:user_id], params: nil)
    end

    def edit
      @user = User.find(params[:user_id])
      if @user.user_profile.blank?
        redirect_to admin_area_user_path(@user), notice: t('helpers.messages.not_registered')
        return
      end
      @user_profile = Admins::UserProfileForm.build(user_id: params[:user_id], id: @user.user_profile.id, params: nil)
    end

    def create
      @user = User.find(params[:user_id])
      @user_profile = Admins::UserProfileForm.build(user_id: params[:user_id], params:)
      if @user_profile.valid?
        @user_profile.perform!

        redirect_to admin_area_user_path(@user), notice: t('helpers.messages.updated')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @user = User.find(params[:user_id])
      @user_profile = Admins::UserProfileForm.build(user_id: params[:user_id], id: @user.user_profile.id, params:)
      if @user_profile.valid?
        @user_profile.perform!
        redirect_to admin_area_user_path(@user), notice: t('helpers.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end
end
