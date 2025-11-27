# typed: strict
# frozen_string_literal: true

class UserEvent < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :user

  sig { params(user: User, event: Type::Base, transaction_time: Time).returns(UserEvent) }
  def self.record!(user:, event:, transaction_time: Time.current)
    raise ArgumentError, 'event must be a UserEvent::Type::Base' unless event.is_a?(Type::Base)
    raise ActiveModel::ValidationError, event unless event.valid?

    create!(
      tenant: user.tenant,
      user: user,
      event_type: event.event_type_name,
      payload: event.to_payload,
      transaction_time: transaction_time
    )
  end
end
