# typed: strict
# frozen_string_literal: true

# Rule to check if user lives in specified prefectures
#
# MR 1 Scope: Config validation only
#
# Config format:
#   {
#     "values": ["13", "27"]
#   }
#
class UserAutoTagging::Rules::PrefectureRule < UserAutoTagging::Rules::AbstractRule
  extend T::Sig

  attribute :values

  validates :values, presence: { message: ->(_object, _data) { I18n.t('auto_tagging.rules.errors.values_empty') } }
  validate :values_must_be_valid_prefecture_codes

  # TODO: MR 2 - Execution methods
  # - events(): [:address_changed]
  # - apply(relation): Filter users by prefecture

  private

  sig { void }
  def values_must_be_valid_prefecture_codes
    return unless values.is_a?(Array)
    return if values.empty?

    if values.any? { |v| v.to_i.zero? && v != '0' }
      errors.add(:values, I18n.t('auto_tagging.rules.errors.prefecture_codes_invalid'))
    end
  end
end
