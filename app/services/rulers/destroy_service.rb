# typed: strict

module Rulers
  class DestroyService < BaseService
    sig { params(ruler: Ruler).returns(T.any(T::Boolean, Ruler)) }
    def execute(ruler:)
      ruler.destroy
    end
  end
end
