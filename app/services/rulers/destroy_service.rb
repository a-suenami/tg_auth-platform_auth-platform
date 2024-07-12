# typed: false

module Rulers
  class DestroyService < BaseService
    def execute(ruler:)
      ruler.destroy
    end
  end
end
