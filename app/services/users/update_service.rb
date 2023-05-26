# typed: false

module Users
  class UpdateService < BaseService
    def execute(user:)
      user.update!(params)
    end
  end
end
