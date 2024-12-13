# typed: strict

module DeliveryAddresses
  class UpdateService < BaseService
    sig { params(delivery_address: DeliveryAddress).returns(DeliveryAddress) }
    def execute(delivery_address:)
      delivery_address.update!(params)
      if delivery_address.is_default
        T.must(delivery_address.user).delivery_addresses.where.not(id: delivery_address.id).update_all(is_default: false)
      end

      # aws event bridgeにイベント発行
      PublishEvents::PublishService.new.execute(user: T.must(delivery_address.user), action_code: :update)
      delivery_address
    end
  end
end
