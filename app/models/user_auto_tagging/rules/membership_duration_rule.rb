# typed: strict
# frozen_string_literal: true

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
class UserAutoTagging::Rules::MembershipDurationRule < UserAutoTagging::Rules::AbstractRule
  extend T::Sig

  VALID_DURATION_UNITS = T.let(%w[days months years].freeze, T::Array[String])

  sig { returns(T.untyped) }
  attr_accessor :values

  sig { returns(T.untyped) }
  attr_accessor :duration_value

  sig { returns(T.untyped) }
  attr_accessor :duration_unit

  validates :values, presence: { message: ->(_object, _data) { I18n.t('auto_tagging.rules.errors.values_empty') } }
  validates :duration_unit, inclusion: {
    in: VALID_DURATION_UNITS,
    message: ->(_object, _data) { I18n.t('auto_tagging.rules.errors.duration_unit_invalid') },
  }
  validate :values_must_be_valid_uuids
  validate :duration_value_must_be_positive

  sig { params(config: T::Hash[String, T.untyped]).void }
  def initialize(config = {})
    super()
    @values = T.let(config['values'], T.untyped)
    @duration_value = T.let(config['duration_value'], T.untyped)
    @duration_unit = T.let(config['duration_unit'], T.untyped)
  end

  # TODO: Execution methods
  # - events(): [:membership_joined, :membership_left, :new_day_arrived]
  # - apply(relation): Filter users who joined membership within duration

  private

  sig { void }
  def values_must_be_valid_uuids
    return unless values.is_a?(Array)
    return if values.empty?

    unless values.all? { |v| v.is_a?(String) && v.present? }
      errors.add(:values, I18n.t('auto_tagging.rules.errors.membership_ids_invalid'))
    end
  end

  sig { void }
  def duration_value_must_be_positive
    unless duration_value.present? && duration_value.to_i.positive?
      errors.add(:duration_value, I18n.t('auto_tagging.rules.errors.duration_value_invalid'))
    end
  end
end
