# frozen_string_literal: true

module API::V1::Authentication
  class LogoutController < ApplicationController
    include CookieAuthable

    def create
      cookie_session.session_clear
      # 異なるドメインのクッキーを削除
      Authentication::DeleteOldSessionService.new.execute(request:, response:)

      head :no_content
    end
  end
end
