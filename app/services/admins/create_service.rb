# typed: false

module Admins
  class CreateService < BaseService
    def execute(email:, name:)
      return false if Admin.find_by(email:).present?

      admin = ActiveRecord::Base.transaction do
        admin = Admin.new(email:, name:)
        admin.save!
        admin.create_auth0_user
        admin.uid = "auth0|#{admin.id}"
        admin.save!
        admin
      end
      admin
    end
  end
end
