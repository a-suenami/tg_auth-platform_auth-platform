# typed: false

module Users
  class DestroyService < BaseService
    def execute(user:)
      user.update!(deleted: true)
    end
  end
end
