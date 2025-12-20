# typed: strict
# frozen_string_literal: true

class DeliveryEvent < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :delivery
  belongs_to :admin, optional: true

  scope :ordered, -> { order(transaction_time: :desc) }

  sig { params(delivery: Delivery, event: Type::Base, admin: T.nilable(Admin), transaction_time: T.any(Time, ActiveSupport::TimeWithZone)).returns(DeliveryEvent) }
  def self.record!(delivery:, event:, admin: nil, transaction_time: Time.zone.now)
    raise ActiveModel::ValidationError, event unless event.valid?

    create!(
      tenant: delivery.tenant,
      delivery: delivery,
      admin: admin,
      event_type: event.event_type_name,
      payload: event.to_payload,
      transaction_time: transaction_time,
    )
  end
end
