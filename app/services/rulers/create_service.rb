# typed: false

module Rulers
  class CreateService < BaseService
    def execute(email:, name:)
      return false if Ruler.find_by(email:).present?

      ruler = ActiveRecord::Base.transaction do
        ruler = Ruler.new(email:, name:)
        ruler.save!
        ruler.create_auth0_user!
        ruler.save!
        ruler
      end
      ruler
    end
  end
end
