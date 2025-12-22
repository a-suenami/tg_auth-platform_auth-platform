# typed: strict
# frozen_string_literal: true

class DeliveryEvent::Type::Failed < DeliveryEvent::Type::Base
  attribute :recipient_id, :string
  attribute :user_id, :string
  attribute :error_message, :string
end
