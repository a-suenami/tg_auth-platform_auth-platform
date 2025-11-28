# typed: strict
# frozen_string_literal: true

module UserTagRules
  # Factory to build rule objects from condition_type and config
  #
  # Provides centralized schema definition and validation instead of
  # hardcoding logic in models.
  #
  # @example
  #   config = {"subscription_type" => "current", "values" => ["1", "2"]}
  #   rule = RuleFactory.build("membership", config)
  #   rule.class #=> UserTagRules::MembershipRule
  #
  # @example Validate config
  #   errors = RuleFactory.validate("membership", config)
  #   errors #=> [] if valid, array of error messages if invalid
  #
  class RuleFactory
    extend T::Sig

    class << self
      extend T::Sig

      # Validate config for a given condition type
      #
      # Note: condition_type validation is handled by Rule model validations
      #
      # @param condition_type [String] Type of condition
      # @param config [Hash] Configuration hash
      # @return [Array<String>] Array of error messages (empty if valid)
      sig { params(condition_type: String, config: T::Hash[String, T.untyped]).returns(T::Array[String]) }
      def validate(condition_type, config)
        case condition_type
        when 'membership'
          MembershipRule.validate_config(config)
        when 'plan'
          PlanRule.validate_config(config)
        when 'age'
          AgeRule.validate_config(config)
        when 'prefecture'
          PrefectureRule.validate_config(config)
        when 'gender'
          GenderRule.validate_config(config)
        when 'account_link'
          AccountLinkRule.validate_config(config)
        else
          # This should never happen if model validations work correctly
          ["Unknown condition_type: #{condition_type}"]
        end
      end

      # Build rule instance from condition type and config
      #
      # @param condition_type [String] Type of condition
      # @param config [Hash] Configuration hash
      # @return [AbstractRule] Rule instance ready for execution
      # @raise [ArgumentError] If condition_type is unknown
      # @example
      #   config = {"subscription_type" => "current", "values" => ["1", "2"]}
      #   rule = RuleFactory.build("membership", config)
      #   rule.events #=> [:membership_joined, :membership_left]
      sig { params(condition_type: String, config: T::Hash[String, T.untyped]).returns(AbstractRule) }
      def build(condition_type, config)
        case condition_type
        when 'membership'
          MembershipRule.from_config(config)
        when 'plan'
          PlanRule.from_config(config)
        when 'age'
          AgeRule.from_config(config)
        when 'prefecture'
          PrefectureRule.from_config(config)
        when 'gender'
          GenderRule.from_config(config)
        when 'account_link'
          AccountLinkRule.from_config(config)
        else
          raise ArgumentError, "Unknown condition_type: #{condition_type}"
        end
      end
    end
  end
end
