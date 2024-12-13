# typed: strict

module AppShopify::Webhooks
  class BaseService
    extend T::Sig

    sig { params(tenant: Tenant, event: T::Hash[T.untyped, T.untyped], multipass_store: ShopifyRecord::MultipassStore).void }
    def initialize(tenant, event, multipass_store)
      @tenant = tenant
      @event = event
      @multipass_store = multipass_store
    end
  end
end
