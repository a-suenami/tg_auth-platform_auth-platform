# typed: false

module Users
  class DestroyService < BaseService
    def execute(user:)
      user.update!(deleted: true, deleted_at: Time.zone.now)

      # ShopifyRecord::Customerが存在する場合、ShopifyCustomerの退会処理を行う
      # shopify_customerは基本１ユーザーにつき１つだが一応複数ある場合も考慮
      begin
        shopify_customers = user.shopify_customers
        shopify_customers.each do |shopify_customer|
          AppShopify::Customer.new(shopify_record_multipass_store: shopify_customer.multipass_store).request_data_erasure(shopify_customer.remote_id)
        end
      rescue Exceptions::Shopify::AdminApiError => e
        # エラーしてもユーザ削除の進行に問題はないのでエラーのキャプチャのみ行う
        Sentry.capture_exception(e)
      end

      # aws event bridgeにイベント発行
      PublishEvents::PublishService.new.execute(user:, action_code: :delete)
    end
  end
end
