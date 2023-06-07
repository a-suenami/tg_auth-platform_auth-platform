module AdminArea
  class UsersController < ApplicationController
    def index
      @users = User.all
      @users = @users.where(id: params[:id]) if params[:id].present?
      @users = @users.where(email: params[:email]) if params[:email].present?
      @email = params[:email]
      @id = params[:id]
      @pagy, @users = pagy @users
    end

    def show
      @user = User.find(params[:id])
    end

  end
end
