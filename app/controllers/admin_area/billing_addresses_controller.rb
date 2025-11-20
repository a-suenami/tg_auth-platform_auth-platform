# typed: true

module AdminArea
  class BillingAddressesController < AdminArea::ApplicationController
    def edit
      @user = User.find(params[:user_id])
    end
  end
end

