# typed: strict
# frozen_string_literal: true

module UserTagRules
  # Rule to check plan subscription duration
  #
  # Config format:
  #   {
  #     "subscription_type": "duration",
  #     "values": ["uuid-1", "uuid-2"],  # Plan IDs
  #     "duration_value": 3,
  #     "duration_unit": "months"
  #   }
  #
  # Triggers: [:plan_joined, :plan_left, :new_day_arrived]
  #
  class PlanDurationRule < AbstractRule
    extend T::Sig

    sig do
      params(
        plan_ids: T::Array[String],
        duration_value: Integer,
        duration_unit: String,
      ).void
    end
    def initialize(plan_ids:, duration_value:, duration_unit:)
      @plan_ids = T.let(plan_ids, T::Array[String])
      @duration_value = T.let(duration_value, Integer)
      @duration_unit = T.let(duration_unit, String)
    end

    # Build rule from config hash
    #
    # @param config [Hash] Configuration hash
    # @return [PlanDurationRule] Rule instance
    sig { params(config: T::Hash[String, T.untyped]).returns(PlanDurationRule) }
    def self.from_config(config)
      new(
        plan_ids: config['values'],
        duration_value: config['duration_value'].to_i,
        duration_unit: config['duration_unit'],
      )
    end

    # Events that trigger this rule
    #
    # @return [Array<Symbol>] Event names
    sig { override.returns(T::Array[Symbol]) }
    def events
      [:plan_joined, :plan_left, :new_day_arrived]
    end

    # Filter users matching plan duration criteria
    #
    # @param relation [ActiveRecord::Relation] Base user relation
    # @return [ActiveRecord::Relation] Filtered relation
    sig { override.params(relation: T.untyped).returns(T.untyped) }
    def apply(relation)
      threshold_date = calculate_threshold_date

      relation
        .joins(<<~SQL.squish)
          INNER JOIN membership_users ON membership_users.user_id = users.id AND membership_users.tenant_id = users.tenant_id
          INNER JOIN membership_contracts ON membership_contracts.id = membership_users.membership_contract_id
          INNER JOIN membership_contract_terms ON membership_contract_terms.membership_contract_id = membership_contracts.id
        SQL
        .where(
          'membership_contract_terms.membership_plan_id IN (?) AND membership_users.created_at <= ?',
          @plan_ids,
          threshold_date,
        )
        .distinct
    end

    # Validate config format
    #
    # @param config [Hash] Configuration hash
    # @return [Array<String>] Array of error messages (empty if valid)
    sig { params(config: T::Hash[String, T.untyped]).returns(T::Array[String]) }
    def self.validate_config(config)
      errors = []

      values = config['values']
      unless values.is_a?(Array) && values.any?
        errors << I18n.t('user_tag_rules.errors.values_empty')
      end

      # Plan IDs are UUIDs (strings), not integers
      if values.is_a?(Array) && !values.all? { |v| v.is_a?(String) && v.present? }
        errors << I18n.t('user_tag_rules.errors.plan_ids_invalid')
      end

      duration_value = config['duration_value']
      unless duration_value.present? && duration_value.to_i.positive?
        errors << I18n.t('user_tag_rules.errors.duration_value_invalid')
      end

      duration_unit = config['duration_unit']
      unless %w[days months years].include?(duration_unit)
        errors << I18n.t('user_tag_rules.errors.duration_unit_invalid')
      end

      errors
    end

    private

    # Calculate threshold date for duration check
    sig { returns(Time) }
    def calculate_threshold_date
      case @duration_unit
      when 'days'
        @duration_value.days.ago
      when 'months'
        @duration_value.months.ago
      when 'years'
        @duration_value.years.ago
      else
        raise ArgumentError, "Invalid duration_unit: #{@duration_unit}"
      end
    end
  end
end
