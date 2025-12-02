# typed: strict

class UserAutoTagging::RuleBlock < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'user_auto_tagging_rule_blocks'

  belongs_to :tenant
  belongs_to :user_auto_tagging

  has_many :rules, class_name: 'UserAutoTagging::Rule', dependent: :destroy, inverse_of: :rule_block

  accepts_nested_attributes_for :rules, allow_destroy: true

  validates :position, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(position: :asc) }

  # MR 2.2: Execution methods

  # Build composite rule combining all rules with AND logic
  #
  # @return [UserTagRules::CompositeRule] Composite rule instance
  # @example
  #   block = RuleBlock.find(123)
  #   block.to_composite_rule #=> CompositeRule([rule1, rule2, ...])
  sig { returns(UserTagRules::CompositeRule) }
  def to_composite_rule
    rule_instances = rules.ordered.map(&:to_rule)
    UserTagRules::CompositeRule.new(rule_instances)
  end

  # Delegate match? and apply to composite rule
  # - match?(user_id) - Check if user matches ALL rules in this block
  # - apply(relation) - Find all users matching ALL rules
  delegate :match?, :apply, to: :to_composite_rule
end
