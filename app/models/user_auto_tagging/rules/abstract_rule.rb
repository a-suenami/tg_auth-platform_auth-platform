# typed: strict
# frozen_string_literal: true

# Base class for all user tag rules
#
# Uses ActiveModel::Validations for config validation
# Each concrete rule class must implement:
# - attr_accessor for config fields
# - validations using ActiveModel::Validations
# - initialize(config) to set attributes from config hash
#
# (TODO): Execution logic
# - events(): List of events that trigger re-evaluation
# - apply(relation): Filter users matching this rule
# - match?(user_id): Check if single user matches
# - and(other_rule): Compose rules with AND logic
#
class UserAutoTagging::Rules::AbstractRule
  extend T::Sig
  extend T::Helpers
  include ActiveModel::Model
  include ActiveModel::Validations

  abstract!

  # Factory method to create instance from config hash
  #
  # @param config [Hash] Configuration hash
  # @return [AbstractRule] Instance of concrete rule class
  sig { params(config: T::Hash[String, T.untyped]).returns(T.attached_class) }
  def self.from_config(config)
    new(config)
  end

  # Validate config format (deprecated - use instance validations)
  #
  # Maintained for backwards compatibility during migration
  #
  # @param config [Hash] Configuration hash
  # @return [Array<String>] Array of error messages (empty if valid)
  sig { params(config: T::Hash[String, T.untyped]).returns(T::Array[String]) }
  def self.validate_config(config)
    instance = from_config(config)
    instance.valid?
    instance.errors.full_messages
  end

  # TODO: Execution methods will be added here
  # - events()
  # - apply(relation)
  # - match?(user_id)
  # - and(other_rule)
end
