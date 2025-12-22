# typed: strict

module Tenants
  class BaseService < ::BaseService
    extend T::Sig

    sig { params(params: ActiveSupport::HashWithIndifferentAccess).void }
    def initialize(params)
      @params = params
    end
  end
end
