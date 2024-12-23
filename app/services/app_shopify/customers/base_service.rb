# typed: false

module AppShopify::Customers
  class BaseService
    DEFAULT_PARAMS = {}.freeze

    def initialize(params = DEFAULT_PARAMS)
      @params = params
    end
  end
end
