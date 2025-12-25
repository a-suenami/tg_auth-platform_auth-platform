# typed: true

module AdminArea
  class UsersController < ApplicationController
    before_action :set_user, only: %i[show edit update destroy reset_sms_ratelimit activities]
    def index
      @users = User.all.includes(:user_profile, tag_assignments: :user_tag)
      @users = @users.where(id: params[:id]) if params[:id].present?
      if params[:email].present?
        users_table = User.arel_table
        email_condition = users_table[:email].matches("%#{ActiveRecord::Base.sanitize_sql_like(params[:email])}%")
        @users = @users.where(email_condition)
      end
      @users = @users.where(phone_number: params[:phone_number]) if params[:phone_number].present?

      # Tag filter - supports multiple tags (OR condition)
      if params[:tag_ids].present?
        tag_ids = Array(params[:tag_ids]).compact_blank
        if tag_ids.any?
          @users = @users.joins(:tag_assignments)
                         .where(user_tag_assignments: { user_tag_id: tag_ids })
                         .distinct
        end
      end

      @user_tags = UserTag.ordered
      @users = @users.includes(:user_profile, :contact_address)
      @pagy, @users = pagy @users

      render_with_ui_toggle('index')
    end

    def show
      if turbo_frame_request? && turbo_frame_request_id == 'detail'
        render partial: 'admin_area/users/user_detail'
      else
        render_with_ui_toggle('show')
      end
    end

    def new
      @user = User.new
      @user.build_user_profile
      render_with_ui_toggle('new')
    end

    def edit
      @user.build_user_profile unless @user.user_profile
      @user.build_contact_address unless @user.contact_address
      render_with_ui_toggle('edit')
    end

    def create
      @user = User.new(create_user_params)
      @user.tenant_id = T.must(Tenant.current_id)

      # Combine country code and local phone number
      if params[:country_code].present? && params[:user][:phone_number_local].present?
        @user.phone_number = "#{params[:country_code]}#{params[:user][:phone_number_local]}"
      end

      # Build user_profile for nested attributes
      @user.build_user_profile unless @user.user_profile

      # Validate user profile using UserProfileForm before saving
      profile_form = build_user_profile_form
      unless profile_form.valid?
        profile_form.errors.each { |error| @user.errors.add("user_profile.#{error.attribute}", error.message) }
        return render_with_ui_toggle('new', status: :unprocessable_entity)
      end

      if @user.save
        # Create user profile after user is saved
        profile_form.user = @user
        profile_form.user_id = @user.id
        profile_form.perform!
        redirect_to admin_area_users_path, notice: 'ユーザーを登録しました'
      else
        render_with_ui_toggle('new', status: :unprocessable_entity)
      end
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

    def create_user_params
      params.require(:user).permit(
        :email,
        :password,
        :phone_number,
        user_profile_attributes: [:first_name, :last_name, :first_name_kana, :last_name_kana, :birth_date, :gender],
      )
    end

    def build_user_profile_form
      tenant = Tenant.find(T.must(Tenant.current_id))
      profile_field_rules = if tenant.tenant_setting&.profile_field_rules.present?
        parsed = JSON.parse(T.must(tenant.tenant_setting).profile_field_rules, symbolize_names: true)
        UserForm::DEFAULT_PROFILE_FIELD_RULES.deep_merge(parsed)
      else
        UserForm::DEFAULT_PROFILE_FIELD_RULES
      end

      form = UserProfileForm.new
      form.current_profile_field_rules = profile_field_rules
      form.tenant_id = Tenant.current_id

      # Set profile attributes from params
      if params[:user][:user_profile_attributes].present?
        profile_params = params[:user][:user_profile_attributes].permit(
          :first_name, :last_name, :first_name_kana, :last_name_kana, :birth_date, :gender,
        )
        form.first_name = profile_params[:first_name]
        form.last_name = profile_params[:last_name]
        form.first_name_kana = profile_params[:first_name_kana]
        form.last_name_kana = profile_params[:last_name_kana]
        form.birth_date = profile_params[:birth_date].present? ? profile_params[:birth_date].to_date : nil
        form.gender = profile_params[:gender]
      end

      form
    end
  end
end
