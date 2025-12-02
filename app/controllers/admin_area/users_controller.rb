# typed: true

module AdminArea
  class UsersController < ApplicationController
    before_action :set_user, only: %i[show edit update destroy reset_sms_ratelimit activities]
    def index
      @users = User.all
      @users = @users.where(id: params[:id]) if params[:id].present?
      if params[:email].present?
        users_table = User.arel_table
        email_condition = users_table[:email].matches("%#{ActiveRecord::Base.sanitize_sql_like(params[:email])}%")
        @users = @users.where(email_condition)
      end
      @users = @users.where(phone_number: params[:phone_number]) if params[:phone_number].present?
      @pagy, @users = pagy @users
    end

    def show
      if turbo_frame_request? && turbo_frame_request_id == 'detail'
        render partial: 'admin_area/users/user_detail'
      else
        render :show
      end
    end

    def edit
      @user.build_user_profile unless @user.user_profile
      @user.build_contact_address unless @user.contact_address
    end

    def update
      if @user.update(user_params)
        redirect_to admin_area_user_path(@user), notice: t('helpers.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def reset_sms_ratelimit
      @user.sms_verifiers.where('created_at > ?', 24.hours.ago).update_all(ignore_in_rate_limit: true)
      redirect_to admin_area_user_path(@user), notice: 'SMS送信制限をリセットしました。'
    end

    def activities
    end

    def destroy
      Users::DestroyService.new.execute(user: @user)
      redirect_to admin_area_users_path, notice: t('helpers.messages.deleted')
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
        :email,
        :enabled,
        :phone_number,
        :sms_verified,
        :email_verified,
        :deleted_at,
        :suppress_sms_verification,
      )
    end
  end
end
