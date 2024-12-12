# typed: true

module API::V1::Internal
  class EmailChangesController < ApplicationController
    # send email address verification email
    def email_change_request
      @user = Users::SendEmailChangeEmailService.new.execute!(user: current_user, email: params[:email])
      head :no_content
    end

    # update email endpoint
    def create
      @user = Users::EmailChangeService.new.execute!(user: current_user, email_verification_code: params[:email_verification_code])

      render 'api/v1/internal/me/show'
    end
  end
end
