# frozen_string_literal: true

module TenantsArea::API::Private
  class UserinfoController < ApplicationController
    before_action -> { doorkeeper_authorize! :uid, :email, :name, :profile, :contact, :delivary_address }, only: :index

    def index
      @doorkeeper_token = doorkeeper_token
      render :index
    end
  end
end
