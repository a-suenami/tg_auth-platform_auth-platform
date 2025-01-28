# typed: true

module ShopifyArea::Webhooks::Eventbridge
  class ShopifyController < ShopifyArea::Webhooks::ApplicationController
    def update
      AppShopify::Webhooks::UpdateService.new(T.must(Tenant.current), params, T.must(@current_shopify_record_multipass_store)).sync_customer
    end
  end
end
