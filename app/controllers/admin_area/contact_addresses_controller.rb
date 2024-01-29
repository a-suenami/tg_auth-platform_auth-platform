module AdminArea
  class ContactAddressesController < AdminArea::ApplicationController
    def new
      @user = User.find(params[:user_id])
      if @user.contact_address.present?
        redirect_to admin_area_user_path(@user), notice: t('helpers.messages.already_registered')
        return
      end
      @contact_address = @user.build_contact_address
    end

    def edit
      @user = User.find(params[:user_id])
      if @user.contact_address.blank?
        redirect_to admin_area_user_path(@user), notice: t('helpers.messages.not_registered')
        return
      end
      @contact_address = @user.contact_address
    end

    def create
      @user = User.find(params[:user_id])
      @contact_address = @user.build_contact_address(contact_address_params)
      if @contact_address.save
        redirect_to admin_area_user_path(@user), notice: t('helpers.messages.updated')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @user = User.find(params[:user_id])
      @contact_address = @user.contact_address
      if @contact_address.update(contact_address_params)
        redirect_to admin_area_user_path(@user), notice: t('helpers.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def contact_address_params
      params.require(:contact_address).permit(
        :zip_code,
        :prefecture_code,
        :city,
        :street,
        :building,
        :phone_number,
        :country_code,
      )
    end
  end
end
