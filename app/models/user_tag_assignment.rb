# typed: strict
# frozen_string_literal: true

class UserTagAssignment < ApplicationRecord
  extend T::Sig
  include Multitenancy

  ASSIGNMENT_TYPES = T.let(%w[manual auto].freeze, T::Array[String])

  # Associations
  belongs_to :tenant
  belongs_to :user
  belongs_to :user_tag
  belongs_to :assigned_by, class_name: 'Admin', optional: true
  belongs_to :user_auto_tagging, optional: true
  belongs_to :removed_by, class_name: 'Admin', optional: true

  # Validations
  validates :assignment_type, presence: true
  validates :assignment_type, inclusion: { in: ASSIGNMENT_TYPES }
  validates :assigned_at, presence: true

  # Custom validations
  validate :manual_assignment_has_admin
  validate :auto_assignment_has_rule
  validate :unique_active_assignment

  # Scopes
  scope :active, -> { where(removed_at: nil) }
  scope :removed, -> { where.not(removed_at: nil) }
  scope :manual, -> { where(assignment_type: 'manual') }
  scope :auto, -> { where(assignment_type: 'auto') }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :for_tag, ->(tag_id) { where(user_tag_id: tag_id) }
  scope :ordered, -> { order(assigned_at: :desc) }

  # Check if assignment is manual
  sig { returns(T::Boolean) }
  def manual?
    assignment_type == 'manual'
  end

  # Check if assignment is auto
  sig { returns(T::Boolean) }
  def auto?
    assignment_type == 'auto'
  end

  # Check if assignment is active (not removed)
  sig { returns(T::Boolean) }
  def active?
    removed_at.nil?
  end

  # Remove this assignment
  sig { params(admin: Admin).void }
  def remove!(admin)
    update!(
      removed_at: Time.current,
      removed_by: admin,
    )
  end

  private

  sig { void }
  def manual_assignment_has_admin
    return unless assignment_type == 'manual' && assigned_by_id.blank?

    errors.add(:assigned_by, 'must be present for manual assignments')
  end

  sig { void }
  def auto_assignment_has_rule
    return unless assignment_type == 'auto' && user_auto_tagging_id.blank?

    errors.add(:user_auto_tagging, 'must be present for auto assignments')
  end

  sig { void }
  def unique_active_assignment
    return if removed_at.present?

    existing = UserTagAssignment
      .active
      .where(user_id: user_id, user_tag_id: user_tag_id)
      .where.not(id: id)
      .exists?

    errors.add(:base, 'User already has this tag assigned') if existing
  end
end
