# frozen_string_literal: true

module TenantsArea::API::Private
  class ApplicationController < TenantsArea::API::ApplicationController
    include DoorkeeperAuthable
  end
end
