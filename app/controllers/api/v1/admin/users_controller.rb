# frozen_string_literal: true

module API::V1::Admin
  class UsersController < ApplicationController
    before_action -> { doorkeeper_authorize! :admin_users }

    def show
      @doorkeeper_token = doorkeeper_token
      # TODO: 連携済みユーザのみ取得できるように
      @user = User.find(params[:id])
      render :show
    end
  end
end
