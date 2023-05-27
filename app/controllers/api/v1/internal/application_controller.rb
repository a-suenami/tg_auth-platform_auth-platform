# frozen_string_literal: true

module API::V1::Internal
  class ApplicationController < API::ApplicationController
    include CookieAuthable
  end
end
