# typed: true
# frozen_string_literal: true

module AdminArea
  module DeliveriesHelper
    extend T::Sig

    # Display birthday timing text based on offset_days
    # @param delivery [Delivery] the delivery object
    # @return [String] formatted timing text
    sig { params(delivery: Delivery).returns(String) }
    def birthday_timing_text(delivery)
      offset = delivery.birthday&.offset_days.to_i
      time = delivery.birthday&.delivery_time

      if offset.positive?
        "誕生日の#{offset}日後 #{time}"
      elsif offset.negative?
        "誕生日の#{offset.abs}日前 #{time}"
      else
        "誕生日当日 #{time}"
      end
    end
  end
end
