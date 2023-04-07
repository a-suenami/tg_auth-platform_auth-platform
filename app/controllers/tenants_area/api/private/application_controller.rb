# frozen_string_literal: true

module TenantsArea::API::Private
  class ApplicationController < ApplicationController
    include DoorkeeperAuthable
  end
end
