# typed: strict

class DeliveryBirthday < ApplicationRecord
  extend T::Sig
  include Multitenancy

  # Status: draft → ongoing ⇄ paused
  #                    ↓
  #               preparing → delivering → (back to ongoing)
  enum :status, {
    draft: 'draft',
    ongoing: 'ongoing',
    preparing: 'preparing',
    delivering: 'delivering',
    paused: 'paused',
  }

  belongs_to :tenant
  belongs_to :delivery
  belongs_to :published_by, class_name: 'Admin', optional: true

  has_many :delivery_results, dependent: :destroy

  validates :delivery_time, presence: true

  sig { returns(T::Boolean) }
  def can_pause?
    ongoing? || preparing?
  end

  sig { returns(T::Boolean) }
  def can_resume?
    paused?
  end

  sig { returns(T::Boolean) }
  def can_publish?
    draft?
  end
end
