# typed: true
# frozen_string_literal: true

module API::V1::Admin
  class ApplicationController < API::ApplicationController
    include DoorkeeperAuthable
  end
end
