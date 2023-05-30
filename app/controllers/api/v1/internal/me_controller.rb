module API::V1::Internal
  class MeController < ApplicationController
    include CookieAuthable

    def show
      render :show
    end
  end
end
