# typed: strict

module API::V1::Admin
  class ApplicationController < API::ApplicationController
    extend T::Sig

    sig { params(scopes: T.untyped).returns(T.untyped) }
    def self.doorkeeper_authorize!(*scopes); end
  end
end
