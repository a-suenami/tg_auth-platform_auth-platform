# typed: strict

class DeliverySchedule < ApplicationRecord
  extend T::Sig
  include Multitenancy

  # Status: draft → scheduled → preparing → delivering → delivered
  #                          ↘ cancelled
  enum :status, {
    draft: 'draft',
    scheduled: 'scheduled',
    preparing: 'preparing',
    delivering: 'delivering',
    delivered: 'delivered',
    cancelled: 'cancelled',
  }

  belongs_to :tenant
  belongs_to :delivery
  belongs_to :published_by, class_name: 'Admin', optional: true

  has_one :delivery_result, dependent: :destroy

  validates :scheduled_at, presence: true
  validate :scheduled_at_must_be_future, if: :draft?

  sig { returns(T::Boolean) }
  def can_cancel?
    scheduled? || preparing?
  end

  sig { returns(T::Boolean) }
  def can_publish?
    draft? && scheduled_at.present?
  end

  private

  sig { void }
  def scheduled_at_must_be_future
    time = scheduled_at
    return if time.blank?

    if time <= Time.current.to_time
      errors.add(:scheduled_at, I18n.t('activerecord.errors.models.delivery_schedule.attributes.scheduled_at.must_be_future'))
    end
  end
end
