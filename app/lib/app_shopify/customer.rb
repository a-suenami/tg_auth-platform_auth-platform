# typed: true

module AppShopify
  class Customer
    extend T::Sig

    sig { void }
    def initialize
      current_tenant = T.let(Tenant.current, T.nilable(Tenant))
      raise Exceptions::Shopify::TenantIsNotFound if current_tenant.nil?

      shopify_record_multipass_setting = current_tenant.shopify_record_multipass_setting
      raise Exceptions::Shopify::ShopifyRecordMultipassSettingNotExist if shopify_record_multipass_setting.nil?

      store_name = shopify_record_multipass_setting.store_name
      api_token = shopify_record_multipass_setting.api_key
      shopify_session = ShopifyAPI::Auth::Session.new(shop: "#{store_name}.myshopify.com", access_token: api_token)
      @client = ShopifyAPI::Clients::Graphql::Admin.new(session: shopify_session)
    end

    sig { params(id: String, email: String).returns(T.untyped) }
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

      response = @client.query(query:, variables: { input: { id:, email: } })
      body = T.cast(response.body, T::Hash[String, T.untyped])

      raise Exceptions::Shopify::AdminApiError.new(error_message: body.dig('errors', 0, 'message'), status: response.code) unless body['errors'].nil?

      # emailが重複した時こっちにエラーが出る
      if body.dig('data', 'customerUpdate', 'userErrors').present?
        raise Exceptions::Shopify::AdminApiError.new(error_message: body.dig('data', 'customerUpdate', 'userErrors', 0, 'message'), status: response.code)
      end

      body
    end
  end
end
