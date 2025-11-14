# typed: strict

class AutoTaggingSchedule < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :user_auto_tagging

  validates :start_at, presence: { if: -> { end_at.present? } }
  validates :end_at, presence: { if: -> { start_at.present? } }
  validate :start_before_end

  sig { returns(T::Boolean) }
  def active?
    return true if start_at.nil? && end_at.nil?
    return false if start_at.nil? || end_at.nil?

    now = Time.current
    now >= start_at && now <= end_at
  end

  private

  sig { void }
  def start_before_end
    return if start_at.nil? || end_at.nil?

    if start_at >= end_at
      errors.add(:end_at, 'must be after start_at')
    end
  end
end
