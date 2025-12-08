# typed: strict

module Deliveries
  class BaseService < ::BaseService
    extend T::Sig

    sig { params(delivery: Delivery, admin: Admin).void }
    def initialize(delivery:, admin:)
      @delivery = delivery
      @admin = admin
    end

    private

    sig { returns(Delivery) }
    attr_reader :delivery

    sig { returns(Admin) }
    attr_reader :admin
  end
end
