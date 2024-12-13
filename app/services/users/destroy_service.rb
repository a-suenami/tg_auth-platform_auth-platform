# typed: strict

module Users
  class DestroyService < BaseService
    sig { params(user: User).void }
    def execute(user:)
      user.update!(deleted: true, deleted_at: Time.zone.now)

      begin
        AppShopify::Customers::DestroyService.new.execute(user:)
      rescue Exceptions::Shopify::AdminApiError => e
        # エラーしてもユーザ削除の進行に問題はないのでエラーのキャプチャのみ行う
        Sentry.capture_exception(e)
      end

      # aws event bridgeにイベント発行
      PublishEvents::PublishService.new.execute(user:, action_code: :delete)
    end
  end
end
