# typed: false

module Users
  class DestroyService < BaseService
    def execute(user:)
      user.update!(deleted: true)
      # 削除済みユーザのAccountLockが残留しないように削除
      if user.account_lock.present?
        user.account_lock.destroy!
      end
      # aws event bridgeにイベント発行
      PublishEvents::PublishService.new.execute(user:, action_code: :delete)
    end
  end
end
