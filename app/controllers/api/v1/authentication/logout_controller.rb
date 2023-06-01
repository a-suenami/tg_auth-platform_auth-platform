# frozen_string_literal: true

module API::V1::Authentication
  class LogoutController < ApplicationController
    include CookieAuthable

    def create
      session[:current_user_id] = nil

      render json: { status: 'ok' }
    end
  end
end
