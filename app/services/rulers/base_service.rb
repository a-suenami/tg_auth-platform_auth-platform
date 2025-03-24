# typed: strict

module Rulers
  class BaseService < ::BaseService
    extend T::Sig
    DEFAULT_PARAMS = T.let({}.freeze, T::Hash[T.untyped, T.untyped])

    sig { params(params: T::Hash[T.untyped, T.untyped]).void }
    def initialize(params = DEFAULT_PARAMS)
      @params = params
    end
  end
end
