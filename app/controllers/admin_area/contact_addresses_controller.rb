# typed: true

module AdminArea
  class ContactAddressesController < AdminArea::ApplicationController
    def new
      @user = User.find(params[:user_id])
      if @user.contact_address.present?
        redirect_to admin_area_user_path(@user), notice: t('helpers.messages.already_registered')
        return
      end
      @contact_address = Admins::ContactAddressForm.build(user_id: params[:user_id], params: nil)
      render_with_ui_toggle(:new)
    end

    def edit
      @user = User.find(params[:user_id])
      if @user.contact_address.blank?
        redirect_to admin_area_user_path(@user), notice: t('helpers.messages.not_registered')
        return
      end
      @contact_address = Admins::ContactAddressForm.build(user_id: params[:user_id], id: @user.contact_address&.id, params: nil)
      render_with_ui_toggle(:edit)
    end

    def create
      @user = User.find(params[:user_id])
      @contact_address = Admins::ContactAddressForm.build(user_id: params[:user_id], params:)
      if @contact_address.valid?
        @contact_address.perform!

        redirect_to admin_area_user_path(@user), notice: t('helpers.messages.updated')
      else
        render_with_ui_toggle(:new, status: :unprocessable_entity)
      end
    end

    def update
      @user = User.find(params[:user_id])
      @contact_address = Admins::ContactAddressForm.build(user_id: params[:user_id], id: @user.contact_address&.id, params:)
      if  @contact_address.valid?
        @contact_address.perform!

        redirect_to admin_area_user_path(@user), notice: t('helpers.messages.updated')
      else
        render_with_ui_toggle(:edit, status: :unprocessable_entity)
      end
    end
  end
end
