# typed: false

module Users
  class EmailVerificationService < BaseService

    def execute(email_confirm_code:, user_id:)
      ActiveRecord::Base.transaction do
        user = User.find_by!(id: user_id, email_confirm_code:)
        user.email_verified = true
        user.save!
        user
      end
    end
  end
end
