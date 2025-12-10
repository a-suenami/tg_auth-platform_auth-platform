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
          validate_membership(config)
        when 'plan'
          validate_plan(config)
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

      # TODO: Rule execution
      # def build(condition_type, config)
      #   Build rule instance for execution
      # end

      private

      # Validate membership rule based on subscription_type
      sig { params(config: T::Hash[String, T.untyped]).returns(T::Array[String]) }
      def validate_membership(config)
        subscription_type = config['subscription_type']
        unless %w[current duration].include?(subscription_type)
          return [I18n.t('user_tag_rules.errors.subscription_type_invalid')]
        end

        if subscription_type == 'duration'
          MembershipDurationRule.validate_config(config)
        else
          MembershipRule.validate_config(config)
        end
      end

      # Validate plan rule based on subscription_type
      sig { params(config: T::Hash[String, T.untyped]).returns(T::Array[String]) }
      def validate_plan(config)
        subscription_type = config['subscription_type']
        unless %w[current duration].include?(subscription_type)
          return [I18n.t('user_tag_rules.errors.subscription_type_invalid')]
        end

        if subscription_type == 'duration'
          PlanDurationRule.validate_config(config)
        else
          PlanRule.validate_config(config)
        end
      end
    end
  end
end
