# typed: false

module Authentication
  class BaseService < ::BaseService
    DEFAULT_PARAMS = {}.freeze

    def initialize(params = DEFAULT_PARAMS)
      @params = params
    end
  end
end
