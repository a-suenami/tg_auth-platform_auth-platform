# typed: true
# frozen_string_literal: true

module API::V1::Authentication
  class LogoutController < ApplicationController
    include CookieAuthable

    def create
      cookie_session.session_clear

      head :no_content
    end
  end
end
