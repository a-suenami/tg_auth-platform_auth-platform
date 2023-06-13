module API::V1::Internal
  class Me::DeliveryAddressesController < ApplicationController
    before_action :set_delivery_address, only: [:show, :update, :destroy]

    def index
      @delivery_addresses = @current_user.delivery_addresses
    end

    def show; end


    def create
      @delivery_address = DeliveryAddresses::CreateService.new(delivery_addresses_params).execute(user: @current_user)
      render :show
    end

    def update
      @delivery_address = DeliveryAddress.find(params[:id])
      @delivery_address = DeliveryAddresses::UpdateService.new(delivery_addresses_params).execute(delivery_address: @delivery_address)
      render :show
    end

    def destroy
      @delivery_address.destroy!
      head :no_content
    end


    private

    def set_delivery_address
      @delivery_address = @current_user.delivery_addresses.find(params[:id])
    end

    def delivery_addresses_params
      params.require(:delivery_addresses).permit(
        :is_default,
        :zip_code,
        :prefecture_code,
        :city,
        :address_1,
        :address_2,
        :contact_tel,
      )
    end
  end
end
