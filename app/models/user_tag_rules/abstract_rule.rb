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

    # TODO: Execution methods will be added here
    # - events()
    # - apply(relation)
    # - match?(user_id)
    # - and(other_rule)
  end
end
