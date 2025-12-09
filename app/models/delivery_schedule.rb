# typed: strict

class DeliverySchedule < ApplicationRecord
  extend T::Sig
  include Multitenancy

  # Status: draft → scheduled → delivering → delivered
  #                          ↘ cancelled
  enum :status, {
    draft: 'draft',
    scheduled: 'scheduled',
    delivering: 'delivering',
    delivered: 'delivered',
    cancelled: 'cancelled',
  }

  belongs_to :tenant
  belongs_to :delivery
  belongs_to :published_by, class_name: 'Admin', optional: true

  validates :scheduled_at, presence: true, unless: :draft?

  sig { returns(T::Boolean) }
  def can_cancel?
    scheduled?
  end

  sig { returns(T::Boolean) }
  def can_publish?
    draft? && scheduled_at.present?
  end
end
