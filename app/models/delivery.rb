# typed: strict

class Delivery < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :template
  belongs_to :created_by, class_name: 'Admin', optional: true
  belongs_to :updated_by, class_name: 'Admin', optional: true

  has_one :schedule, class_name: 'DeliverySchedule', dependent: :destroy
  has_one :birthday, class_name: 'DeliveryBirthday', dependent: :destroy

  has_many :delivery_user_tags, dependent: :destroy
  has_many :user_tags, through: :delivery_user_tags
  has_many :delivery_recipients, dependent: :destroy
  has_many :delivery_events, dependent: :destroy
  has_many :delivery_results, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validate :must_have_user_tags

  scope :ordered, -> { order(created_at: :desc) }
  scope :search_by_name, lambda { |term|
    return all if term.blank?

    where(arel_table[:name].lower.matches("%#{sanitize_sql_like(term.downcase)}%"))
  }

  sig { returns(T::Boolean) }
  def schedule_type?
    schedule.present?
  end

  sig { returns(T::Boolean) }
  def birthday_type?
    birthday.present?
  end

  sig { returns(T.nilable(String)) }
  def delivery_type
    if schedule.present?
      'schedule'
    elsif birthday.present?
      'birthday'
    end
  end

  sig { returns(T.nilable(String)) }
  def status
    schedule&.status || birthday&.status
  end

  # Recipient statistics for monitoring
  sig { returns(T::Hash[Symbol, Integer]) }
  def recipient_stats
    recipients = delivery_recipients.group(:status).count
    total = recipients.values.sum
    {
      total: total,
      pending: recipients['pending'] || 0,
      sent: recipients['sent'] || 0,
      failed: recipients['failed'] || 0,
    }
  end

  # Check if all recipients are in terminal state (sent or failed)
  sig { returns(T::Boolean) }
  def all_processed?
    delivery_recipients.exists? && delivery_recipients.where(status: 'pending').empty?
  end

  sig { returns(Float) }
  def success_rate
    total = delivery_recipients.count
    return 0.0 if total.zero?

    sent = delivery_recipients.sent.count
    T.cast((sent.to_f / total * 100).round(2), Float)
  end

  # Get single result for schedule type deliveries (backward compatibility)
  sig { returns(T.nilable(DeliveryResult)) }
  def delivery_result
    delivery_results.first
  end

  private

  sig { void }
  def must_have_user_tags
    if user_tag_ids.blank? || user_tag_ids.compact_blank.empty?
      errors.add(:user_tags, 'を選択してください')
    end
  end
end
