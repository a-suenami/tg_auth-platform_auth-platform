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

  VALID_DURATION_UNITS = T.let(%w[days months years].freeze, T::Array[String])

  attribute :values
  attribute :duration_value
  attribute :duration_unit

  validates :values, presence: { message: ->(_object, _data) { I18n.t('auto_tagging.rules.errors.values_empty') } }
  validates :duration_unit, inclusion: {
    in: VALID_DURATION_UNITS,
    message: ->(_object, _data) { I18n.t('auto_tagging.rules.errors.duration_unit_invalid') },
  }
  validate :values_must_be_valid_uuids
  validate :duration_value_must_be_positive

  # TODO: Execution methods
  # - events(): [:plan_joined, :plan_left, :new_day_arrived]
  # - apply(relation): Filter users who joined plan within duration

  private

  # Plan IDs are UUIDs (strings), not integers
  sig { void }
  def values_must_be_valid_uuids
    return unless values.is_a?(Array)
    return if values.empty?

    unless values.all? { |v| v.is_a?(String) && v.present? }
      errors.add(:values, I18n.t('auto_tagging.rules.errors.plan_ids_invalid'))
    end
  end

  sig { void }
  def duration_value_must_be_positive
    unless duration_value.present? && duration_value.to_i.positive?
      errors.add(:duration_value, I18n.t('auto_tagging.rules.errors.duration_value_invalid'))
    end
  end
end
