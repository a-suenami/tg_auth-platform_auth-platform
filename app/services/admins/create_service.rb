# typed: false

module Admins
  class CreateService < BaseService
    def execute(email:, name:)
      return false if Admin.find_by(email:).present?

      ruler = ActiveRecord::Base.transaction do
        ruler = Admin.new(email:, name:)
        ruler.save!
        ruler.create_auth0_user
        ruler.uid = "auth0|#{ruler.id}"
        ruler.save!
        ruler
      end
      ruler
    end
  end
end
