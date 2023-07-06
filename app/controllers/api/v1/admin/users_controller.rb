# frozen_string_literal: true

module API::V1::Admin
  class UsersController < ApplicationController
    before_action -> { doorkeeper_authorize! :admin_users }

    def index
      @doorkeeper_token = doorkeeper_token
      users = current_application.users.includes(:user_profile, :contact_address, :delivery_addresses)

      if params[:start_at].present? && params[:end_at].present?
        @start_at = Time.zone.parse(params[:start_at])
        @end_at = Time.zone.parse(params[:end_at])
        users = users.merge(
          users.where(updated_at: @start_at..@end_at)
            .or(users.where(user_profile: { updated_at: @start_at..@end_at }))
            .or(users.where(contact_address: { updated_at: @start_at..@end_at })),
        )
      end
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
