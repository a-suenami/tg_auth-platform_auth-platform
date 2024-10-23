module ShopifyArea::Webhooks::Eventbridge
  class ShopifyController < ShopifyArea::Webhooks::ApplicationController
    def update
      AppShopify::Webhooks::UpdateService.new(Tenant.current, params).sync_customer
    end
  end
end
