# typed: false

module AppShopify::Customers
  class BaseService
    def initialize(tenant, multipass_store)
      @tenant = tenant
      @multipass_store = multipass_store
    end
  end
end
