class BaseService
  attr_accessor :params

  def initialize(params = {})
    @params = params
  end

  def execute
  end

  def execute!
  end
end
