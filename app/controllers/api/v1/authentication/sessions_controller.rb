# frozen_string_literal: true

module API::V1::Authentication
  class SessionsController < ApplicationController

    def create
      user = Authentication::SessionCreateService.new.execute!(email: params[:email], password: params[:password])
      cookie_session[:current_user_id] = user.id


      render :create, locals: { user: }
    end
  end
end
