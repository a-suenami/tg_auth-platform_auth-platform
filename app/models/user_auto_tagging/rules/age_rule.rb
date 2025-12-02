# typed: strict
# frozen_string_literal: true

# Rule to check if user's age falls within specified range
#
# Config format:
#   {
#     "min": 20,
#     "max": 65
#   }
#
class UserAutoTagging::Rules::AgeRule < UserAutoTagging::Rules::AbstractRule
  extend T::Sig

  attribute :min
  attribute :max

  validate :min_must_be_valid_integer
  validate :max_must_be_valid_integer
  validate :max_must_be_greater_than_min
  validate :at_least_one_value_required

  # TODO: Execution methods
  # - events(): [:birthday_changed, :new_day_arrived]
  # - apply(relation): Filter users by age range

  private

  sig { void }
  def min_must_be_valid_integer
    return if min.blank?

    unless min.is_a?(Integer) && !min.negative?
      errors.add(:min, I18n.t('auto_tagging.rules.errors.age_min_invalid'))
    end
  end

  sig { void }
  def max_must_be_valid_integer
    return if max.blank?

    unless max.is_a?(Integer) && !max.negative?
      errors.add(:max, I18n.t('auto_tagging.rules.errors.age_max_invalid'))
    end
  end

  sig { void }
  def max_must_be_greater_than_min
    return if min.blank? || max.blank?
    return unless min.is_a?(Integer) && max.is_a?(Integer)

    if min >= max
      errors.add(:max, I18n.t('auto_tagging.rules.errors.age_max_less_than_min'))
    end
  end

  sig { void }
  def at_least_one_value_required
    if min.blank? && max.blank?
      errors.add(:base, I18n.t('auto_tagging.rules.errors.age_both_blank'))
    end
  end
end
