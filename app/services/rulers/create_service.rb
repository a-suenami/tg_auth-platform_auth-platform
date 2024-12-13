# typed: strict

module Rulers
  class CreateService < BaseService
    sig { params(email: String, name: String).returns(T.any(Ruler, T::Boolean)) }
    def execute(email:, name:)
      return false if Ruler.find_by(email:).present?

      ruler = ActiveRecord::Base.transaction do
        new_ruler = Ruler.new(email:, name:)
        new_ruler.save!
        new_ruler.create_auth0_user!
        new_ruler.save!
        new_ruler
      end
      ruler
    end
  end
end
