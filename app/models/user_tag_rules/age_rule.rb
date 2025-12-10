# typed: strict
# frozen_string_literal: true

module UserTagRules
  # Rule to check if user's age falls within specified range
  #
  # Config format:
  #   {
  #     "min": 20,
  #     "max": 65
  #   }
  #
  class AgeRule < AbstractRule
    extend T::Sig

    sig { params(min_age: T.nilable(Integer), max_age: T.nilable(Integer)).void }
    def initialize(min_age: nil, max_age: nil)
      @min_age = T.let(min_age, T.nilable(Integer))
      @max_age = T.let(max_age, T.nilable(Integer))
    end

    # TODO: Execution methods
    # - events(): [:birthday_changed, :new_day_arrived]
    # - apply(relation): Filter users by age range

    # Validate config format
    #
    # @param config [Hash] Configuration hash
    # @return [Array<String>] Array of error messages (empty if valid)
    sig { params(config: T::Hash[String, T.untyped]).returns(T::Array[String]) }
    def self.validate_config(config)
      errors = []

      min_age = config['min']
      max_age = config['max']

      if min_age.present? && (!min_age.is_a?(Integer) || min_age.negative?)
        errors << I18n.t('user_tag_rules.errors.age_min_invalid')
      end

      if max_age.present? && (!max_age.is_a?(Integer) || max_age.negative?)
        errors << I18n.t('user_tag_rules.errors.age_max_invalid')
      end

      if min_age.present? && max_age.present? && min_age >= max_age
        errors << I18n.t('user_tag_rules.errors.age_max_less_than_min')
      end

      if min_age.blank? && max_age.blank?
        errors << I18n.t('user_tag_rules.errors.age_both_blank')
      end

      errors
    end

    # TODO: Build rule from config
  end
end
