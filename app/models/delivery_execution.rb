# typed: strict

class DeliveryExecution < ApplicationRecord
  extend T::Sig
  include Multitenancy

  # Enum (auto-generate: pending?, pending!, DeliveryExecution.pending scope, etc.)
  enum :status, {
    pending: 'pending',
    sent: 'sent',
    failed: 'failed',
    skipped: 'skipped',
  }

  belongs_to :tenant
  belongs_to :delivery
  belongs_to :user

  validates :delivery_id, uniqueness: { scope: :user_id }

  scope :scheduled_before, ->(time) { where('scheduled_for <= ?', time) }

  sig { params(error: String).void }
  def mark_failed!(error)
    update!(status: 'failed', error_message: error)
  end

  sig { void }
  def mark_sent!
    update!(status: 'sent', sent_at: Time.current)
  end

  sig { params(reason: String).void }
  def mark_skipped!(reason)
    update!(status: 'skipped', error_message: reason)
  end
end
