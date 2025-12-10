# typed: strict
# frozen_string_literal: true

module UserTagRules
  # Composite rule that combines multiple rules with AND logic
  #
  # MR 1 Scope: Not used for config validation (only for MR 2 execution)
  # MR 2 Scope: Combines multiple rules with AND logic
  #
  # Users must match ALL composed rules to match the composite rule.
  #
  # @example MR 2 usage
  #   rule = CompositeRule.new([
  #     MembershipRule.new(membership_ids: [1, 2]),
  #     AgeRule.new(min_age: 20, max_age: 65)
  #   ])
  #   rule.match?(123)  #=> true only if user matches both rules
  #
  class CompositeRule < AbstractRule
    extend T::Sig

    sig { params(rules: T::Array[AbstractRule]).void }
    def initialize(rules)
      @rules = T.let(rules, T::Array[AbstractRule])
    end

    # CompositeRule does not support config-based validation
    #
    # This rule is built from other rule objects, not from config hash.
    # Use RuleFactory.validate() for individual rule configs instead.
    #
    # @param _config [Hash] Not used
    # @return [Array<String>] Error message
    sig { override.params(_config: T::Hash[String, T.untyped]).returns(T::Array[String]) }
    def self.validate_config(_config)
      [I18n.t('user_tag_rules.errors.composite_not_supported')]
    end

    # Collect all unique events from composed rules
    #
    # @return [Array<Symbol>] Unique events from all rules
    # @example
    #   rules = [membership_rule, age_rule]
    #   events #=> [:membership_joined, :membership_left, :birthday_changed, :new_day_arrived]
    sig { override.returns(T::Array[Symbol]) }
    def events
      @rules.flat_map(&:events).uniq
    end

    # Apply all rules sequentially with AND logic
    #
    # Each rule filters the relation, producing progressively smaller result sets.
    #
    # @param relation [ActiveRecord::Relation] Base relation
    # @return [ActiveRecord::Relation] Relation matching ALL rules
    # @example
    #   apply(User.all)
    #   # => User.where(membership: ...).where(age: ...)
    sig { override.params(relation: T.untyped).returns(T.untyped) }
    def apply(relation)
      @rules.reduce(relation) { |rel, rule| rule.apply(rel) }
    end

    # Compose with another rule by adding to the rule list
    #
    # @param other_rule [AbstractRule] Rule to add
    # @return [CompositeRule] New composite with added rule
    # @example
    #   composite.and(prefecture_rule)  # Adds prefecture to existing rules
    sig { override.params(other_rule: AbstractRule).returns(CompositeRule) }
    def and(other_rule)
      CompositeRule.new(@rules + [other_rule])
    end
  end
end
