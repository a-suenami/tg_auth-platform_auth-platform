# typed: false

module Users
  class PasswordResetService < BaseService

    def execute!(email:, password_reset_code:)
      # email validate
      unless email =~ URI::MailTo::EMAIL_REGEXP
        raise Exceptions::Services::Users::InvalidEmail
      end

      ActiveRecord::Base.transaction do
        user = User.find_by(email:, enabled: true)
        if user.blank?
          # TODO: error message
          raise Exceptions::Services::Users::BaseError
        end

        password_reset = Users::PasswordReset.find_by!(user:, code: password_reset_code, expired_at: Time.zone.now..)
        if password_reset.used_at.blank?
          user.update!(params)
        else
          # TODO: error message
          raise Exceptions::Services::Users::BaseError
        end
      end
    end
  end
end
