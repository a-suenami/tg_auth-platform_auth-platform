# typed: true

module DeliveryAddresses
  class CreateService < BaseService

    def execute(user:)
      ActiveRecord::Base.transaction do
        delivery_address = user.delivery_addresses.new(params)
        delivery_address.is_default = true if delivery_address.user&.delivery_addresses.blank?
        delivery_address.save!
        if delivery_address.is_default
          user.delivery_addresses.where.not(id: delivery_address.id).update_all(is_default: false)
        end
        # aws event bridgeにイベント発行
        PublishEvents::PublishService.new.execute(user:, action_code: :update)
        delivery_address
      end
    end
  end
end
