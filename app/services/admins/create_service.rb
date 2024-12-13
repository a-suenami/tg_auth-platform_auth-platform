# typed: strict

module Admins
  class CreateService < BaseService
    sig { params(email: String, name: String).returns(T.any(Admin, T::Boolean)) }
    def execute(email:, name:)
      return false if Admin.find_by(email:).present?

      admin = ActiveRecord::Base.transaction do
        new_admin = Admin.new(email:, name:)
        new_admin.save!
        new_admin.create_auth0_user!
        new_admin.save!
        new_admin
      end
      admin
    end
  end
end
