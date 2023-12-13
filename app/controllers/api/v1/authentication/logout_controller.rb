# frozen_string_literal: true

module API::V1::Authentication
  class LogoutController < ApplicationController
    include CookieAuthable

    def create
      cookie_session.session_clear
      # 旧domainのクッキーがある場合削除
      Authentication::DeleteOldSessionService.new.execute(request:)

      head :no_content
    end
  end
end
