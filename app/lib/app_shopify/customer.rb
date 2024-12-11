# typed: true

module AppShopify
  class Customer
    extend T::Sig

    sig { params(shopify_record_multipass_store: ShopifyRecord::MultipassStore).void }
    def initialize(shopify_record_multipass_store:)
      current_tenant = T.let(Tenant.current, T.nilable(Tenant))
      raise Exceptions::Shopify::TenantIsNotFound if current_tenant.nil?

      store_name = shopify_record_multipass_store.store_name
      api_token = shopify_record_multipass_store.api_key
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

      # emailが重複した場合、対象のcustomerが存在しなかった場合、こっちにエラーが出る
      if body.dig('data', 'customerUpdate', 'userErrors').present?
        # ともに通常運用でエラーは起きず、shopify側の管理画面を一方的に操作し場合に起こるエラー。
        # 対象のcustomerが見つからない場合はemail更新の必要がないので、エラーのキャプチャのみ行う
        Sentry.capture_exception(Exceptions::Shopify::AdminApiError.new(error_message: body.dig('data', 'customerUpdate', 'userErrors', 0, 'message'), status: response.code))
      end

      body
    end

    # ShopifyCustomerの退会処理
    # 個人情報の削除をShopifyが遅延して削除を行う
    sig { params(remote_id: String).returns(T.untyped) }
    def request_data_erasure(remote_id)
      query = <<-GRAPHQL
        mutation customerRequestDataErasure($customerId: ID!) {
          customerRequestDataErasure(customerId: $customerId) {
            customerId
            userErrors {
              field
              message
            }
          }
        }
      GRAPHQL

      customer_id = "gid://shopify/Customer/#{remote_id}"

      response = @client.query(query:, variables: { customerId: customer_id })
      body = T.cast(response.body, T::Hash[String, T.untyped])

      raise Exceptions::Shopify::AdminApiError.new(error_message: body.dig('errors', 0, 'message'), status: response.code) unless body['errors'].nil?

      # 対象のcustomerが存在しなかった場合、こっちにエラーが出る
      if body.dig('data', 'customerRequestDataErasure', 'userErrors').present?
        # 対象のcustomerが見つからない場合はemail更新の必要がないので、エラーのキャプチャのみ行う
        Sentry.capture_exception(Exceptions::Shopify::AdminApiError.new(error_message: body.dig('data', 'customerRequestDataErasure', 'userErrors', 0, 'message'), status: response.code))
      end

      body
    end
  end
end
