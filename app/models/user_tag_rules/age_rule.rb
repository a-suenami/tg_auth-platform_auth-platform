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

    # MR 2.1: Execution methods

    # Build rule from config hash
    #
    # @param config [Hash] Configuration hash
    # @return [AgeRule] Rule instance
    sig { params(config: T::Hash[String, T.untyped]).returns(AgeRule) }
    def self.from_config(config)
      new(
        min_age: config['min'],
        max_age: config['max'],
      )
    end

    # Events that trigger this rule
    #
    # @return [Array<Symbol>] Event names
    sig { override.returns(T::Array[Symbol]) }
    def events
      [:profile_updated, :new_day_arrived]
    end

    # Filter users matching age criteria
    #
    # @param relation [ActiveRecord::Relation] Base user relation
    # @return [ActiveRecord::Relation] Filtered relation
    sig { override.params(relation: T.untyped).returns(T.untyped) }
    def apply(relation)
      return relation.none if @min_age.nil? && @max_age.nil?

      result = relation
        .joins('INNER JOIN user_profiles ON user_profiles.user_id = users.id AND user_profiles.tenant_id = users.tenant_id')

      today = Time.zone.today

      if @max_age
        # Max age N means born on or after (N+1) years ago
        min_birth_date = today - (@max_age + 1).years + 1.day
        result = result.where('user_profiles.birth_date >= ?', min_birth_date)
      end

      if @min_age
        # Min age N means born on or before N years ago
        max_birth_date = today - @min_age.years
        result = result.where('user_profiles.birth_date <= ?', max_birth_date)
      end

      result.distinct
    end

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
  end
end
