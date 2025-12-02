# typed: strict
# frozen_string_literal: true

# Factory to build rule objects from condition_type and config
#
# Provides centralized schema definition and validation instead of
# hardcoding logic in models.
#
# @example
#   config = {"subscription_type" => "current", "values" => ["1", "2"]}
#   rule = RuleFactory.build("membership", config)
#   rule.class #=> UserAutoTagging::Rules::MembershipRule
#
# @example Validate config
#   errors = RuleFactory.validate("membership", config)
#   errors #=> [] if valid, array of error messages if invalid
#
class UserAutoTagging::Rules::RuleFactory
  extend T::Sig

  VALID_SUBSCRIPTION_TYPES = T.let(%w[current duration].freeze, T::Array[String])

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
      klass = rule_class_for(condition_type, config)
      return ["Unknown condition_type: #{condition_type}"] if klass.nil?
      return [I18n.t('auto_tagging.rules.errors.subscription_type_invalid')] if klass == :invalid_subscription_type

      rule = klass.from_config(config)
      rule.valid?
      rule.errors.full_messages
    end

    # Build rule instance from condition_type and config
    #
    # @param condition_type [String] Type of condition
    # @param config [Hash] Configuration hash
    # @return [AbstractRule, nil] Rule instance or nil if unknown condition_type or invalid subscription_type
    sig { params(condition_type: String, config: T::Hash[String, T.untyped]).returns(T.nilable(AbstractRule)) }
    def build(condition_type, config)
      klass = rule_class_for(condition_type, config)
      return nil if klass.nil? || klass == :invalid_subscription_type

      klass.from_config(config)
    end

    private

    # Get rule class for condition_type and config
    #
    # @param condition_type [String] Type of condition
    # @param config [Hash] Configuration hash
    # @return [Class, Symbol, nil] Rule class, :invalid_subscription_type, or nil if unknown
    sig { params(condition_type: String, config: T::Hash[String, T.untyped]).returns(T.any(T.class_of(AbstractRule), Symbol, NilClass)) }
    def rule_class_for(condition_type, config)
      case condition_type
      when 'membership'
        membership_rule_class(config)
      when 'plan'
        plan_rule_class(config)
      when 'age'
        AgeRule
      when 'prefecture'
        PrefectureRule
      when 'gender'
        GenderRule
      when 'account_link'
        AccountLinkRule
      end
    end

    # Get membership rule class based on subscription_type
    #
    # @param config [Hash] Configuration hash
    # @return [Class, :invalid_subscription_type, nil]
    sig { params(config: T::Hash[String, T.untyped]).returns(T.any(T.class_of(AbstractRule), Symbol, NilClass)) }
    def membership_rule_class(config)
      subscription_type = config['subscription_type']
      return :invalid_subscription_type unless VALID_SUBSCRIPTION_TYPES.include?(subscription_type)

      subscription_type == 'duration' ? MembershipDurationRule : MembershipRule
    end

    # Get plan rule class based on subscription_type
    #
    # @param config [Hash] Configuration hash
    # @return [Class, :invalid_subscription_type, nil]
    sig { params(config: T::Hash[String, T.untyped]).returns(T.any(T.class_of(AbstractRule), Symbol, NilClass)) }
    def plan_rule_class(config)
      subscription_type = config['subscription_type']
      return :invalid_subscription_type unless VALID_SUBSCRIPTION_TYPES.include?(subscription_type)

      subscription_type == 'duration' ? PlanDurationRule : PlanRule
    end
  end
end
