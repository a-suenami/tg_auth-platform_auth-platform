# typed: strict
# frozen_string_literal: true

# Rule to check plan subscription duration
#
# Config format:
#   {
#     "values": ["uuid-1", "uuid-2"],  # Plan IDs
#     "duration_value": 3,
#     "duration_unit": "months"
#   }
#
# Triggers: [:plan_joined, :plan_left, :new_day_arrived]
#
class UserAutoTagging::Rules::PlanDurationRule < UserAutoTagging::Rules::AbstractRule
  extend T::Sig

  sig do
    params(
      plan_ids: T::Array[String],
      duration_value: Integer,
      duration_unit: String,
    ).void
  end
  def initialize(plan_ids:, duration_value:, duration_unit:)
    @plan_ids = T.let(plan_ids, T::Array[String])
    @duration_value = T.let(duration_value, Integer)
    @duration_unit = T.let(duration_unit, String)
  end

  # TODO: Execution methods
  # - events(): [:plan_joined, :plan_left, :new_day_arrived]
  # - apply(relation): Filter users who joined plan within duration

  # Validate config format
  #
  # @param config [Hash] Configuration hash
  # @return [Array<String>] Array of error messages (empty if valid)
  sig { params(config: T::Hash[String, T.untyped]).returns(T::Array[String]) }
  def self.validate_config(config)
    errors = []

    values = config['values']
    unless values.is_a?(Array) && values.any?
      errors << I18n.t('auto_tagging.rules.errors.values_empty')
    end

    # Plan IDs are UUIDs (strings), not integers
    if values.is_a?(Array) && !values.all? { |v| v.is_a?(String) && v.present? }
      errors << I18n.t('auto_tagging.rules.errors.plan_ids_invalid')
    end

    duration_value = config['duration_value']
    unless duration_value.present? && duration_value.to_i.positive?
      errors << I18n.t('auto_tagging.rules.errors.duration_value_invalid')
    end

    duration_unit = config['duration_unit']
    unless %w[days months years].include?(duration_unit)
      errors << I18n.t('auto_tagging.rules.errors.duration_unit_invalid')
    end

    errors
  end
end
