# typed: strict
# frozen_string_literal: true

# Rule to check user's gender
#
# Config format:
#   {
#     "values": ["male", "female"]
#   }
#
class UserAutoTagging::Rules::GenderRule < UserAutoTagging::Rules::AbstractRule
  extend T::Sig

  VALID_GENDERS = T.let(%w[male female].freeze, T::Array[String])

  attribute :values

  validates :values, presence: { message: ->(_object, _data) { I18n.t('auto_tagging.rules.errors.values_empty') } }
  validate :values_must_be_valid_genders

  # TODO: Execution methods
  # - events(): [:profile_updated]
  # - apply(relation): Filter users by gender

  private

  sig { void }
  def values_must_be_valid_genders
    return unless values.is_a?(Array)
    return if values.empty?

    unless values.all? { |v| VALID_GENDERS.include?(v) }
      errors.add(:values, I18n.t('auto_tagging.rules.errors.gender_values_invalid'))
    end
  end
end
