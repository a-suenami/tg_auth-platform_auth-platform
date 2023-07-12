# frozen_string_literal: true

module API::V1::Admin
  class ApplicationController < API::ApplicationController
    include Pagy::Backend

    def current_application
      raise Exceptions::Auth::AccessTokenExpired if doorkeeper_token.expired?

      @current_application ||= doorkeeper_token.application
    end
  end
end
