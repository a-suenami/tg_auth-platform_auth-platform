# typed: false

module AppShopify::Customers
  class DestroyService < BaseService
    def execute(user:)
      # ShopifyRecord::Customerが存在する場合、ShopifyCustomerの退会処理を行う
      # shopify_customerは基本１ユーザーにつき１つだが一応複数ある場合も考慮
      shopify_customers = user.shopify_customers
      shopify_customers.each do |shopify_customer|
        client = AppShopify::Customer.new(shopify_record_multipass_store: shopify_customer.multipass_store)
        client.request_data_erasure(shopify_customer.remote_id)
        client.unsubscribe_email_marketing(shopify_customer.remote_id)
      end
    end
  end
end
