# typed: strict
# frozen_string_literal: true

# Rule to check current plan subscription
#
# Config format:
#   {
#     "values": ["uuid-1", "uuid-2"]  # Plan IDs
#   }
#
# Triggers: [:plan_joined, :plan_left]
#
class UserAutoTagging::Rules::PlanRule < UserAutoTagging::Rules::AbstractRule
  extend T::Sig

  sig { params(plan_ids: T::Array[String]).void }
  def initialize(plan_ids:)
    @plan_ids = T.let(plan_ids, T::Array[String])
  end

  # TODO: Execution methods
  # - events(): [:plan_joined, :plan_left]
  # - apply(relation): Filter users with current plan in @plan_ids

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

    errors
  end
end
