# frozen_string_literal: true

module API::V1::Admin
  class UsersController < ApplicationController
    before_action -> { doorkeeper_authorize! :admin_users }

    def index
      @doorkeeper_token = doorkeeper_token
      users = current_application.users
      _pagy, users = pagy(users)
      # TODO: linked_application.scopesを反映させる
      render :index, locals: { users: }
    end

    def show
      @doorkeeper_token = doorkeeper_token
      user = current_application.users.find(params[:id])
      # TODO: linked_application.scopesを反映させる
      render :show, locals: { user: }
    end

  end
end
