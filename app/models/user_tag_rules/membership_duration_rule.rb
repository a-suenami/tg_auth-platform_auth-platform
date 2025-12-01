# typed: strict
# frozen_string_literal: true

module UserTagRules
  # Rule to check membership subscription duration
  #
  # Config format:
  #   {
  #     "values": ["uuid-1", "uuid-2"],  # Membership IDs
  #     "duration_value": 3,
  #     "duration_unit": "months"
  #   }
  #
  # Triggers: [:membership_joined, :membership_left, :new_day_arrived]
  #
  class MembershipDurationRule < AbstractRule
    extend T::Sig

    sig do
      params(
        membership_ids: T::Array[String],
        duration_value: Integer,
        duration_unit: String,
      ).void
    end
    def initialize(membership_ids:, duration_value:, duration_unit:)
      @membership_ids = T.let(membership_ids, T::Array[String])
      @duration_value = T.let(duration_value, Integer)
      @duration_unit = T.let(duration_unit, String)
    end

    # TODO: Execution methods
    # - events(): [:membership_joined, :membership_left, :new_day_arrived]
    # - apply(relation): Filter users who joined membership within duration

    # Validate config format
    #
    # @param config [Hash] Configuration hash
    # @return [Array<String>] Array of error messages (empty if valid)
    sig { params(config: T::Hash[String, T.untyped]).returns(T::Array[String]) }
    def self.validate_config(config)
      errors = []

      values = config['values']
      unless values.is_a?(Array) && values.any?
        errors << I18n.t('user_tag_rules.errors.values_empty')
      end

      if values.is_a?(Array) && !values.all? { |v| v.is_a?(String) && v.present? }
        errors << I18n.t('user_tag_rules.errors.membership_ids_invalid')
      end

      duration_value = config['duration_value']
      unless duration_value.present? && duration_value.to_i.positive?
        errors << I18n.t('user_tag_rules.errors.duration_value_invalid')
      end

      duration_unit = config['duration_unit']
      unless %w[days months years].include?(duration_unit)
        errors << I18n.t('user_tag_rules.errors.duration_unit_invalid')
      end

      errors
    end
  end
end
