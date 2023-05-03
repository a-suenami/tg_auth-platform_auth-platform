# frozen_string_literal: true

module API::V1::Private
  class ApplicationController < API::ApplicationController
    include DoorkeeperAuthable
  end
end
