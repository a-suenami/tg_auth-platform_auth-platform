# typed: strict

module Admins
  class DestroyService < BaseService
    sig { params(admin: Admin).void }
    def execute(admin:)
      admin.destroy
    end
  end
end
