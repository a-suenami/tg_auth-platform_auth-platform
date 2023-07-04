# typed: false

module DeliveryAddresses
  class UpdateService < BaseService
    def execute(delivery_address:)
      delivery_address.update(params)
      delivery_address.zip_code = delivery_address&.zip_code&.delete('-') if delivery_address.zip_code.present?
      delivery_address.save!
      if delivery_address.is_default
        delivery_address.user.delivery_addresses.where.not(id: delivery_address.id).update_all(is_default: false)
      end
      delivery_address
    end
  end
end
