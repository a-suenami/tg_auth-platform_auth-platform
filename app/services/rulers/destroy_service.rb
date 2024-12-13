# typed: strict

module Rulers
  class DestroyService < BaseService
    sig { params(ruler: Ruler).void }
    def execute(ruler:)
      ruler.destroy
    end
  end
end
