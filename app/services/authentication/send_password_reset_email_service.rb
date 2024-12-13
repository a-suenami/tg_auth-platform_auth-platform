# typed: strict

module Authentication
  class SendPasswordResetEmailService < BaseService

    sig do
      params(
        email: String,
        base_url: String,
      ).returns(T.nilable(User))
    end
    def execute!(email:, base_url:)
      # email validate
      unless email =~ URI::MailTo::EMAIL_REGEXP
        raise Exceptions::Authentication::InvalidEmail
      end

      ActiveRecord::Base.transaction do
        user = find_active_user(email:)

        if user.blank?
          # アカウントの存在を隠すため、エラーせずそのまま返す
          next true
        end

        password_reset = Users::PasswordReset.new(user:)
        password_reset.set_code
        password_reset.save!

        send_verification_email(user, password_reset, base_url)
        user
      end
    end

    sig { params(user: User, password_reset: Users::PasswordReset, base_url: String).void }
    def send_verification_email(user, password_reset, base_url)
      # query encode
      params = {
        password_reset_code: password_reset.code,
      }.to_query
      password_reset_url = "#{base_url}?#{params}"

      template_params = { password_reset_url: }.transform_keys(&:to_s)

      User::SendEmailWorker.perform_async(T.must(Tenant.current_id), 'password_reset', template_params, user.email)
    end

    sig { params(email: String).returns(T.nilable(User)) }
    def find_active_user(email:)
      # emailそのまま + email.downcaseでユーザを検索する
      user = User.active.find_by(email:, email_verified: true)
      user = User.active.find_by(email: email.downcase, email_verified: true) if user.nil?
      user
    end
  end
end
