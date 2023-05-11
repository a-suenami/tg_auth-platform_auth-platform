# typed: false

module Users
  class BaseService < ::BaseService
    DEFAULT_PARAMS = {}.freeze

    def initialize(params = DEFAULT_PARAMS)
      @params = params
    end
  end
end
