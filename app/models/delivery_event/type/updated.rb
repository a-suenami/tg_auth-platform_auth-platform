# typed: strict
# frozen_string_literal: true

class DeliveryEvent::Type::Updated < DeliveryEvent::Type::Base
  attribute :changes, :string

  # Optional: store what changed
end
