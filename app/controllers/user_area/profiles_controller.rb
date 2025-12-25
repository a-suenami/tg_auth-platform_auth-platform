# typed: true
# frozen_string_literal: true

module UserArea
  class ProfilesController < ApplicationController
    before_action :require_login
    before_action :load_user_form

    helper_method :field_editable?

    # プロフィール登録・編集画面
    def edit
      @user = current_user
    end

    # プロフィール更新
    def update
      if @user_form.valid?
        @user_form.perform!
        current_user.reload

        if current_user.enabled?
          redirect_after_profile_complete
        else
          flash.now[:error] = I18n.t('user_area.profiles.required_fields')
          @user = current_user
          render :edit, status: :unprocessable_entity
        end
      else
        flash.now[:error] = @user_form.errors.full_messages.join(', ')
        @user = current_user
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def require_login
      return if cookie_session[:current_user_id].present?

      redirect_to login_path
    end

    def current_user
      @current_user ||= User.find(cookie_session[:current_user_id])
    end

    def load_user_form
      @user_form = UserForm.build(id: current_user.id, params: request.post? || request.patch? ? params : nil)
      @profile_field_rules = @user_form.current_profile_field_rules
    end

    def redirect_after_profile_complete
      if cookie_session[:auth_url].present?
        redirect_to cookie_session[:auth_url]
      else
        flash[:notice] = I18n.t('user_area.profiles.saved')
        redirect_to edit_profile_path
      end
    end

    # 既に値が設定されている場合は editable ルールに従う
    # 未設定の場合は常に編集可能
    def field_editable?(table_name, field)
      rules = @profile_field_rules[table_name][field]
      return true if rules[:editable]

      # editable: false でも、まだ値が設定されていない場合は編集可能
      case table_name
      when :user_profiles
        current_user.user_profile&.public_send(field).blank?
      when :contact_address
        current_user.contact_address&.public_send(field).blank?
      else
        true
      end
    end
  end
end
