# typed: strict
# frozen_string_literal: true

class DeliveryEvent::Type::Sent < DeliveryEvent::Type::Base
  attribute :recipient_id, :string
  attribute :user_id, :string
end
