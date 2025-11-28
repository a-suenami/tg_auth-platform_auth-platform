# typed: strict

class UserAutoTagging < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :created_by, class_name: 'Admin'
  belongs_to :updated_by, class_name: 'Admin', optional: true

  has_one :schedule, class_name: 'AutoTaggingSchedule', dependent: :destroy
  has_many :rule_blocks, class_name: 'UserAutoTagging::RuleBlock', dependent: :destroy
  has_many :tag_assignments, class_name: 'UserTagAssignment', dependent: :destroy

  accepts_nested_attributes_for :schedule, allow_destroy: true
  accepts_nested_attributes_for :rule_blocks, allow_destroy: true

  validates :name, presence: true
  validates :name, uniqueness: { scope: :tenant_id }
  validates :enabled, inclusion: { in: [true, false] }
  validates :shareable, inclusion: { in: [true, false] }

  scope :enabled, -> { where(enabled: true) }
  scope :ordered, -> { order(created_at: :desc) }
  scope :search_by_name, lambda { |term|
    return all if term.blank?

    where(arel_table[:name].lower.matches("%#{sanitize_sql_like(term.downcase)}%"))
  }

  sig { returns(T.nilable(String)) }
  def created_by_name
    created_by&.name
  end

  sig { returns(T.nilable(String)) }
  def updated_by_name
    updated_by&.name
  end

  # MR 2.2: Execution methods

  # Get all unique events that trigger this auto-tagging rule
  #
  # Collects events from all rule blocks (all rules within blocks)
  #
  # @return [Array<Symbol>] Unique event names
  # @example
  #   tagging.events #=> [:membership_joined, :membership_left, :profile_updated]
  sig { returns(T::Array[Symbol]) }
  def events
    rule_blocks.flat_map do |block|
      block.to_composite_rule.events
    end.uniq
  end

  # Check if a specific user matches ANY rule block (OR logic)
  #
  # User matches if they satisfy ALL rules in AT LEAST ONE block
  #
  # @param user_id [String] User UUID
  # @return [Boolean] True if user matches any rule block
  # @example
  #   tagging.match?('user-uuid-123') #=> true
  sig { params(user_id: String).returns(T::Boolean) }
  def match?(user_id)
    rule_blocks.any? { |block| block.match?(user_id) }
  end

  # Find all users matching ANY rule block (OR logic)
  #
  # Returns union of users matching each rule block
  #
  # @param relation [ActiveRecord::Relation] Base user relation (default: User.all)
  # @return [ActiveRecord::Relation] Users matching any rule block
  # @example
  #   tagging.find_matching_users(User.where(tenant_id: 'abc'))
  #   #=> User.where(id: [...])
  sig { params(relation: T.untyped).returns(T.untyped) }
  def find_matching_users(relation = nil)
    base_relation = relation || User.all

    # Collect user IDs from each rule block (OR logic)
    user_ids = rule_blocks.flat_map do |block|
      block.apply(base_relation).pluck(:id)
    end.uniq

    # Return relation with matching user IDs
    base_relation.where(id: user_ids)
  end

  # Check if this auto-tagging is currently active
  #
  # Considers both enabled flag and schedule period
  #
  # @return [Boolean] True if active
  # @example
  #   tagging.active? #=> true
  sig { returns(T::Boolean) }
  def active?
    return false unless enabled

    schedule ? T.must(schedule).active? : true
  end
end
