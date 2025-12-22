# typed: strict

class DeliveryResult < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :delivery
  belongs_to :delivery_schedule, optional: true
  belongs_to :delivery_birthday, optional: true

  validates :blastengine_delivery_id, uniqueness: true

  sig { returns(Integer) }
  def error_count
    drop_count + soft_error_count + hard_error_count
  end

  sig { returns(Float) }
  def success_rate
    return 0.0 if total_count.zero?

    T.cast((sent_count.to_f / total_count * 100).round(2), Float)
  end

  sig { returns(Float) }
  def open_rate
    return 0.0 if sent_count.zero?

    T.cast((open_count.to_f / sent_count * 100).round(2), Float)
  end
end
