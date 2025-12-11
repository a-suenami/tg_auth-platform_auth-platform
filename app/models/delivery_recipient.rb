# typed: strict

class DeliveryRecipient < ApplicationRecord
  extend T::Sig
  include Multitenancy

  enum :status, {
    pending: 'pending',
    sent: 'sent',
    failed: 'failed',
  }

  belongs_to :tenant
  belongs_to :delivery
  belongs_to :user

  # Unique per delivery + user + date (allows same user to receive birthday email yearly)
  validates :delivery_id, uniqueness: { scope: [:user_id, :delivery_date] }

  scope :for_delivery, ->(delivery_id) { where(delivery_id: delivery_id) }
  scope :for_date, ->(date) { where(delivery_date: date) }
end
