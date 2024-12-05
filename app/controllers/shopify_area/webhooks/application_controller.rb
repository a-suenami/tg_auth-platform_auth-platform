module ShopifyArea::Webhooks
  class ApplicationController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods

    before_action :set_tenant
    before_action :set_current_shopify_record_multipass_store
    before_action :authenticate

    private

    def set_tenant
      RequestStore.store[:current_tenant_domain] = request.host || '-'
      Tenant.current
    end

    def set_current_shopify_record_multipass_store
      store_name = params.dig(:detail, :metadata, :'X-Shopify-Shop-Domain').split('.').first
      @current_shopify_record_multipass_store = Tenant.current.shopify_record_multipass_stores.find_by!(store_name:)
    end

    def authenticate
      authenticate_or_request_with_http_token do |token, _options|
        # Compare the tokens in a time-constant manner, to mitigate
        # timing attacks.
        ActiveSupport::SecurityUtils.secure_compare(
          ::Digest::SHA256.hexdigest(token),
          ::Digest::SHA256.hexdigest(@current_shopify_record_multipass_store.webhook_token),
        )
      end
    end
  end
end
