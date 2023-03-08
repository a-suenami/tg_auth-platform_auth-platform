# frozen_string_literal: true

module AdminArea
  class ApplicationController < ActionController::Base
    include Pagy::Backend

    def root
      flash[:alert] = 'this is an example message' # rubocop:disable Rails
      flash[:notice] = 'you can also use notice level flash' # rubocop:disable Rails
    end
  end
end
