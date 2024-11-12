# typed: false

module AppShopify
  class Customer
    def initialize
      store_name = Tenant.current.shopify_record_multipass_setting.store_name
      api_token = Tenant.current.shopify_record_multipass_setting.api_key
      shopify_session = ShopifyAPI::Auth::Session.new(shop: "#{store_name}.myshopify.com", access_token: api_token)
      @client = ShopifyAPI::Clients::Graphql::Admin.new(session: shopify_session)
    end

    def update_email(id, email)
      query = <<-GRAPHQL
        mutation customerUpdate($input: CustomerInput!) {
          customerUpdate(input: $input) {
            customer {
              id
              email
              multipassIdentifier
            }
            userErrors {
              field
              message
            }
          }
        }
      GRAPHQL

      result = @client.query(query:, variables: { input: { id:, email: } })

      # エラーがある場合
      raise result.errors.messages[:data].first unless result.errors.empty?

      result.data.customer_update.customer
    end
  end
end
