# typed: false

module AppShopify::Webhooks
  class BaseService
    def initialize(tenant, event)
      @tenant = tenant
      @event = event
    end
  end
end
