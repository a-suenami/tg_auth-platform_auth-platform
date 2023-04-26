# frozen_string_literal: true

module TenantsArea::API
  class OauthController < ApplicationController

    def login
      # clientが存在するかチェック
      OauthFirstPartyApplication.find_by!(uid: params[:client_id])

      user = User.find_by(email: params[:email])
      if user&.authenticate(params[:password])
        # create session
        session[:current_user_id] = user.id

        render json: { status: 'ok' }
      else
        render json: { status: 'error' }
      end
    end

    def logout
      client = OauthFirstPartyApplication.find_by(uid: params[:client_id])

      if client.present? && client.vaild_return_to?(params[:returnTo])
        session[:current_user_id] = nil
        redirect_to params[:returnTo], allow_other_host: true
      else
        render :error, formats: :html
      end
    end

    def signup
      user = Users::CreateService.new(singup_params).execute
      if user.persisted?
        # TODO: send email
        render json: { status: 'ok' }
      else
        render json: { status: 'error' }
      end
    rescue ActiveRecord::RecordNotUnique => e
      handle_400(error_details: ['すでに登録されているメールアドレスです。'])
    end

    def password_change
    end

    private
    def singup_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
  end
end
