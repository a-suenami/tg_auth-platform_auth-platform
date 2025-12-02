# typed: true

module AdminArea
  class BillingAddressesController < AdminArea::ApplicationController
    def new
      @user = User.find(params[:user_id])
    end

    def edit
      @user = User.find(params[:user_id])
    end
  end
end
