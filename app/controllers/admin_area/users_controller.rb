module AdminArea
  class UsersController < ApplicationController
    def index
      @users = User.all
      @users = @users.where(id: params[:id]) if params[:id].present?
      @users = @users.where('email ILIKE :param', param: "%#{ActiveRecord::Base.sanitize_sql_like(params[:email] || '')}%") if params[:email].present?
      @users = @users.where(phone_number: params[:phone_number]) if params[:phone_number].present?
      @pagy, @users = pagy @users
    end

    def show
      @user = User.find(params[:id])
    end

    def edit
      @user = User.find(params[:id])
      @user.build_user_profile unless @user.user_profile
      @user.build_contact_address unless @user.contact_address
    end

    def update
      @user = User.find(params[:id])
      if @user.update(user_params)
        redirect_to admin_area_user_path(@user), notice: t('helpers.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(
        :email,
        :enabled,
        :phone_number,
        :sms_verified,
        :email_verified,
        :deleted,
        :lock_expired_at,
      )
    end
  end
end
