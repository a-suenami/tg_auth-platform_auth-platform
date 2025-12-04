# typed: strict

class Delivery < ApplicationRecord
  extend T::Sig
  include Multitenancy

  enum :status, {
    draft: 'draft',
    scheduled: 'scheduled',
    delivering: 'delivering',
    delivered: 'delivered',
    cancelled: 'cancelled',
    paused: 'paused',
  }

  enum :delivery_type, {
    datetime: 'datetime',
    birthday: 'birthday',
  }, prefix: true 

  belongs_to :tenant
  belongs_to :template
  belongs_to :created_by, class_name: 'Admin', optional: true
  belongs_to :updated_by, class_name: 'Admin', optional: true
  belongs_to :published_by, class_name: 'Admin', optional: true

  has_many :delivery_user_tags, dependent: :destroy
  has_many :user_tags, through: :delivery_user_tags
  has_many :delivery_executions, dependent: :destroy
  has_many :delivery_activities, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :scheduled_at, presence: true, if: :delivery_type_datetime?
  validates :birthday_delivery_time, presence: true, if: :delivery_type_birthday?
  validate :status_matches_delivery_type

  scope :ordered, -> { order(created_at: :desc) }

  sig { returns(T::Boolean) }
  def can_cancel?
    delivery_type_datetime? && scheduled?
  end

  sig { returns(T::Boolean) }
  def can_pause?
    delivery_type_birthday? && scheduled?
  end

  sig { returns(T::Boolean) }
  def can_resume?
    delivery_type_birthday? && paused?
  end

  private

  sig { void }
  def status_matches_delivery_type
    if cancelled? && !delivery_type_datetime?
      errors.add(:status, 'cancelled is only valid for datetime type')
    end
    if paused? && !delivery_type_birthday?
      errors.add(:status, 'paused is only valid for birthday type')
    end
  end
end
