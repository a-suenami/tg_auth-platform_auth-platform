# typed: strict
# frozen_string_literal: true

module UserTagRules
  # Base class for all user tag rules
  #
  # Config validation only
  # Each concrete rule class must implement:
  # - self.validate_config(config): Validate config hash and return array of error messages
  #
  # (TODO): Execution logic
  # - events(): List of events that trigger re-evaluation
  # - apply(relation): Filter users matching this rule
  # - match?(user_id): Check if single user matches
  # - and(other_rule): Compose rules with AND logic
  #
  class AbstractRule
    extend T::Sig
    extend T::Helpers

    abstract!

    # Validate config format
    #
    # Subclasses must override this method to provide validation logic
    #
    # @param config [Hash] Configuration hash
    # @return [Array<String>] Array of error messages (empty if valid)
    sig { params(config: T::Hash[String, T.untyped]).returns(T::Array[String]) }
    def self.validate_config(config)
      raise NotImplementedError, "#{name} must implement validate_config class method"
    end

    # MR 2.1: Execution methods

    # Returns array of events that should trigger this rule's re-evaluation
    #
    # @return [Array<Symbol>] Event names (e.g., [:membership_joined, :profile_updated])
    # @example
    #   MembershipRule.new(membership_ids: [1]).events
    #   #=> [:membership_joined, :membership_left]
    sig { returns(T::Array[Symbol]) }
    def events
      raise NotImplementedError, "#{self.class.name} must implement events method"
    end

    # Filters an ActiveRecord relation to only users matching this rule
    #
    # @param relation [ActiveRecord::Relation] Base relation (usually User.all)
    # @return [ActiveRecord::Relation] Filtered relation
    # @example
    #   rule = MembershipRule.new(membership_ids: [1, 2])
    #   rule.apply(User.all)
    #   #=> User.joins(:memberships).where(memberships: { id: [1, 2] })
    sig { params(relation: T.untyped).returns(T.untyped) }
    def apply(relation)
      raise NotImplementedError, "#{self.class.name} must implement apply method"
    end

    # Checks if a specific user matches this rule
    #
    # Default implementation uses apply() on single-user relation
    # Subclasses can override for optimization
    #
    # @param user_id [String] User UUID
    # @return [Boolean] True if user matches rule
    # @example
    #   rule.match?('user-uuid-123') #=> true
    sig { params(user_id: String).returns(T::Boolean) }
    def match?(user_id)
      apply(User.where(id: user_id)).exists?
    end

    # Composes this rule with another using AND logic
    #
    # @param other_rule [AbstractRule] Rule to combine with
    # @return [CompositeRule] New composite rule
    # @example
    #   age_rule.and(membership_rule)
    #   #=> CompositeRule([age_rule, membership_rule])
    sig { params(other_rule: AbstractRule).returns(CompositeRule) }
    def and(other_rule)
      CompositeRule.new([self, other_rule])
    end
  end
end
