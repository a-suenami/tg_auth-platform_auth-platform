# typed: false

module StripeRecords
  class BaseService < ::BaseService
    def initialize(tenant_stripe_account:)
      @tenant_stripe_account = tenant_stripe_account
    end
  end
end
