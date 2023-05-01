# typed: strict

module Exceptions
  class BaseError < StandardError
    extend T::Sig

    sig { returns(String) }
    def inspect
      "#<#{self.class}: #{message}>"
    end
  end
end
