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

  sig { returns(T.untyped) }
  attr_accessor :values

  validates :values, presence: { message: ->(_object, _data) { I18n.t('auto_tagging.rules.errors.values_empty') } }
  validate :values_must_be_valid_uuids

  sig { params(config: T::Hash[String, T.untyped]).void }
  def initialize(config = {})
    super()
    @values = T.let(config['values'], T.untyped)
  end

  # TODO: Execution methods
  # - events(): [:plan_joined, :plan_left]
  # - apply(relation): Filter users with current plan in @values

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
end
