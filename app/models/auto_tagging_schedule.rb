# typed: strict

class AutoTaggingSchedule < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :user_auto_tagging

  validate :both_dates_present_or_both_null
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
  def both_dates_present_or_both_null
    if start_at.present? && end_at.blank?
      errors.add(:end_at, 'must be present if start_at is present')
    elsif end_at.present? && start_at.blank?
      errors.add(:start_at, 'must be present if end_at is present')
    end
  end

  sig { void }
  def start_before_end
    return if start_at.nil? || end_at.nil?

    if T.must(start_at) >= end_at
      errors.add(:end_at, 'must be after start_at')
    end
  end
end
