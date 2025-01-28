# typed: strict

module DeliveryAddresses
  class BaseService < ::BaseService
    extend T::Sig
    DEFAULT_PARAMS = T.let({}.freeze, T::Hash[T.untyped, T.untyped])

    sig { params(params: T.any(T::Hash[T.untyped, T.untyped], ActionController::Parameters)).void }
    def initialize(params = DEFAULT_PARAMS)
      @params = params
    end
  end
end
