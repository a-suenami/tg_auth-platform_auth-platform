# typed: false

module Users
  class DestroyService < BaseService
    def execute(user:)
      user.update!(deleted: true, deleted_at: Time.zone.now)
      # aws event bridgeにイベント発行
      PublishEvents::PublishService.new.execute(user:, action_code: :delete)
    end
  end
end
