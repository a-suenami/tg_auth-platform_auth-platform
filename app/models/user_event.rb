# typed: strict
# frozen_string_literal: true

class UserEvent < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :user

  after_commit :publish_to_eventbridge, on: :create

  sig { params(user: User, event: Type::Base, transaction_time: T.any(Time, ActiveSupport::TimeWithZone)).returns(UserEvent) }
  def self.record!(user:, event:, transaction_time: Time.zone.now)
    raise ActiveModel::ValidationError, event unless event.valid?

    create!(
      tenant: user.tenant,
      user: user,
      event_type: event.event_type_name,
      payload: event.to_payload,
      transaction_time: transaction_time,
    )
  end

  private

  sig { void }
  def publish_to_eventbridge
    PublishEvents::PublishWorker.perform_async(id)
  end
end
