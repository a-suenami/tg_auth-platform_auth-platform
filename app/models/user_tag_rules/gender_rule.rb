# typed: strict
# frozen_string_literal: true

module UserTagRules
  # Rule to check user's gender
  #
  # Config format:
  #   {
  #     "values": ["male", "female", "other"]
  #   }
  #
  class GenderRule < AbstractRule
    extend T::Sig

    sig { params(genders: T::Array[String]).void }
    def initialize(genders:)
      @genders = T.let(genders, T::Array[String])
    end

    # MR 2.1: Execution methods

    # Build rule from config hash
    #
    # @param config [Hash] Configuration hash
    # @return [GenderRule] Rule instance
    sig { params(config: T::Hash[String, T.untyped]).returns(GenderRule) }
    def self.from_config(config)
      new(
        genders: config['values'],
      )
    end

    # Events that trigger this rule
    #
    # @return [Array<Symbol>] Event names
    sig { override.returns(T::Array[Symbol]) }
    def events
      [:profile_updated]
    end

    # Filter users matching gender criteria
    #
    # Note: "other" matches users with gender = "other", NULL, or blank
    # (i.e., all users who are not explicitly male or female)
    #
    # @param relation [ActiveRecord::Relation] Base user relation
    # @return [ActiveRecord::Relation] Filtered relation
    sig { override.params(relation: T.untyped).returns(T.untyped) }
    def apply(relation)
      base_query = relation
        .joins('INNER JOIN user_profiles ON user_profiles.user_id = users.id AND user_profiles.tenant_id = users.tenant_id')

      conditions = []
      params = []

      # Handle male/female
      explicit_genders = @genders & ['male', 'female']
      if explicit_genders.any?
        conditions << 'user_profiles.gender IN (?)'
        params << explicit_genders
      end

      # Handle "other" (includes other/nil/blank)
      if @genders.include?('other')
        conditions << '(user_profiles.gender NOT IN (?) OR user_profiles.gender IS NULL OR user_profiles.gender = ?)'
        params << ['male', 'female']
        params << ''
      end

      base_query.where(conditions.join(' OR '), *params).distinct
    end

    # Validate config format
    sig { params(config: T::Hash[String, T.untyped]).returns(T::Array[String]) }
    def self.validate_config(config)
      errors = []

      values = config['values']
      unless values.is_a?(Array) && values.any?
        errors << I18n.t('user_tag_rules.errors.values_empty')
      end

      if values.is_a?(Array) && !values.all? { |v| %w[male female other].include?(v) }
        errors << I18n.t('user_tag_rules.errors.gender_values_invalid')
      end

      errors
    end
  end
end
