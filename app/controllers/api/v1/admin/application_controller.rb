# typed: strict
# frozen_string_literal: true

module API::V1::Admin
  class ApplicationController < API::ApplicationController
    include Pagy::Backend

    sig { returns(T.nilable(OauthApplication)) }
    def current_application
      raise Exceptions::Auth::AccessTokenExpired if doorkeeper_token.expired?

      @current_application ||= T.let(doorkeeper_token.application, T.nilable(OauthApplication))
    end
  end
end
