# typed: false

module AppShopify::Webhooks
  class BaseService
    def initialize(tenant, event, multipass_store)
      @tenant = tenant
      @event = event
      @multipass_store = multipass_store
    end
  end
end
