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
  has_many :delivery_executions, dependent: :destroy
  has_many :delivery_events, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validate :must_have_user_tags

  scope :ordered, -> { order(created_at: :desc) }

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

  private

  sig { void }
  def must_have_user_tags
    if user_tag_ids.blank? || user_tag_ids.compact_blank.empty?
      errors.add(:user_tags, 'を選択してください')
    end
  end
end
