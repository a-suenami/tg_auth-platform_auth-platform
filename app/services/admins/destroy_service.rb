# typed: false

module Admins
  class DestroyService < BaseService
    def execute(admin:)
      admin.destroy
    end
  end
end
