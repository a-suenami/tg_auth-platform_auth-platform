# typed: strict
# frozen_string_literal: true

module UserTagRules
  # Rule to check membership subscription (current or duration)
  #
  # Config format for current subscription:
  #   {
  #     "subscription_type": "current",
  #     "values": ["1", "2", "3"]  # Membership IDs
  #   }
  #
  # Config format for duration subscription:
  #   {
  #     "subscription_type": "duration",
  #     "values": ["1", "2"],
  #     "duration_value": 6,
  #     "duration_unit": "months"
  #   }
  #
  class MembershipRule < AbstractRule
    extend T::Sig

    sig do
      params(
        membership_ids: T::Array[String],
        subscription_type: String,
        duration_value: T.nilable(Integer),
        duration_unit: T.nilable(String),
      ).void
    end
    def initialize(membership_ids:, subscription_type:, duration_value: nil, duration_unit: nil)
      @membership_ids = T.let(membership_ids, T::Array[String])
      @subscription_type = T.let(subscription_type, String)
      @duration_value = T.let(duration_value, T.nilable(Integer))
      @duration_unit = T.let(duration_unit, T.nilable(String))
    end

    # TODO: Execution methods
    # - events(): [:membership_joined, :membership_left] (current)
    #            [:membership_joined, :membership_left, :new_day_arrived] (duration)
    # - apply(relation): Filter users based on subscription_type

    # Validate config format
    #
    # @param config [Hash] Configuration hash
    # @return [Array<String>] Array of error messages (empty if valid)
    sig { params(config: T::Hash[String, T.untyped]).returns(T::Array[String]) }
    def self.validate_config(config)
      errors = []

      subscription_type = config['subscription_type']
      unless %w[current duration].include?(subscription_type)
        errors << I18n.t('user_tag_rules.errors.subscription_type_invalid')
        return errors
      end

      values = config['values']
      unless values.is_a?(Array) && values.any?
        errors << I18n.t('user_tag_rules.errors.values_empty')
      end

      if values.is_a?(Array) && !values.all? { |v| v.is_a?(String) && v.present? }
        errors << I18n.t('user_tag_rules.errors.membership_ids_invalid')
      end

      # Validate duration-specific fields
      if subscription_type == 'duration'
        duration_value = config['duration_value']
        unless duration_value.present? && duration_value.to_i.positive?
          errors << I18n.t('user_tag_rules.errors.duration_value_invalid')
        end

        duration_unit = config['duration_unit']
        unless %w[days months years].include?(duration_unit)
          errors << I18n.t('user_tag_rules.errors.duration_unit_invalid')
        end
      end

      errors
    end

    # TODO: Build rule from config
  end
end
