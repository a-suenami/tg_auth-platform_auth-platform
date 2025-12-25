# typed: true
# frozen_string_literal: true

module UserArea
  class MypageController < ApplicationController
    before_action :require_login

    def show
      @user = current_user
    end

    private

    def require_login
      return if cookie_session[:current_user_id].present?

      redirect_to login_path
    end

    def current_user
      @current_user ||= User.find(cookie_session[:current_user_id])
    end
  end
end
