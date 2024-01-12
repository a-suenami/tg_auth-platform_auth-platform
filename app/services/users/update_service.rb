# typed: false

module Users
  class UpdateService < BaseService
    def execute(user:)
      user.update!(params)

      # TODO: 電話番号が確認済みの場合、電話番号を変更できないように

      # aws event bridgeにイベント発行
      PublishEvents::PublishService.new.execute(user:, action_code: :update)

      true
    end
  end
end
