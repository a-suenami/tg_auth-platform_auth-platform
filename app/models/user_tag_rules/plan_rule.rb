# typed: strict
# frozen_string_literal: true

module UserTagRules
  # Rule to check plan subscription (current or duration)
  #
  # Config format for current subscription:
  #   {
  #     "subscription_type": "current",
  #     "values": ["5", "6"]  # Plan IDs
  #   }
  #
  # Config format for duration subscription:
  #   {
  #     "subscription_type": "duration",
  #     "values": ["5", "6"],
  #     "duration_value": 6,
  #     "duration_unit": "months"
  #   }
  #
  class PlanRule < AbstractRule
    extend T::Sig

    sig do
      params(
        plan_ids: T::Array[String],
        subscription_type: String,
        duration_value: T.nilable(Integer),
        duration_unit: T.nilable(String),
      ).void
    end
    def initialize(plan_ids:, subscription_type:, duration_value: nil, duration_unit: nil)
      @plan_ids = T.let(plan_ids, T::Array[String])
      @subscription_type = T.let(subscription_type, String)
      @duration_value = T.let(duration_value, T.nilable(Integer))
      @duration_unit = T.let(duration_unit, T.nilable(String))
    end

    # MR 2.1: Execution methods

    # Build rule from config hash
    #
    # @param config [Hash] Configuration hash
    # @return [PlanRule] Rule instance
    sig { params(config: T::Hash[String, T.untyped]).returns(PlanRule) }
    def self.from_config(config)
      new(
        plan_ids: config['values'],
        subscription_type: config['subscription_type'],
        duration_value: config['duration_value']&.to_i,
        duration_unit: config['duration_unit'],
      )
    end

    # Events that trigger this rule
    #
    # @return [Array<Symbol>] Event names
    sig { override.returns(T::Array[Symbol]) }
    def events
      base_events = [:membership_joined, :membership_left]
      @subscription_type == 'duration' ? base_events + [:new_day_arrived] : base_events
    end

    # Filter users matching plan criteria
    #
    # @param relation [ActiveRecord::Relation] Base user relation
    # @return [ActiveRecord::Relation] Filtered relation
    sig { override.params(relation: T.untyped).returns(T.untyped) }
    def apply(relation)
      if @subscription_type == 'current'
        apply_current(relation)
      else
        apply_duration(relation)
      end
    end

    # Validate config format
    #
    # @param config [Hash] Configuration hash
    # @return [Array<String>] Array of error messages (empty if valid)
    sig { params(config: T::Hash[String, T.untyped]).returns(T::Array[String]) }
    def self.validate_config(config)
      errors = []

      subscription_type = config['subscription_type']
      unless %w[current duration].include?(subscription_type)
        errors << I18n.t('user_tag_rules.errors.subscription_type_invalid')
        return errors
      end

      values = config['values']
      unless values.is_a?(Array) && values.any?
        errors << I18n.t('user_tag_rules.errors.values_empty')
      end

      # Plan IDs are UUIDs (strings), not integers
      if values.is_a?(Array) && !values.all? { |v| v.is_a?(String) && v.present? }
        errors << I18n.t('user_tag_rules.errors.plan_ids_invalid')
      end

      # Validate duration-specific fields
      if subscription_type == 'duration'
        duration_value = config['duration_value']
        unless duration_value.present? && duration_value.to_i.positive?
          errors << I18n.t('user_tag_rules.errors.duration_value_invalid')
        end

        duration_unit = config['duration_unit']
        unless %w[days months years].include?(duration_unit)
          errors << I18n.t('user_tag_rules.errors.duration_unit_invalid')
        end
      end

      errors
    end

    private

    # Filter users with current active plan subscription
    sig { params(relation: T.untyped).returns(T.untyped) }
    def apply_current(relation)
      relation
        .joins(<<~SQL.squish)
          INNER JOIN membership_users ON membership_users.user_id = users.id AND membership_users.tenant_id = users.tenant_id
          INNER JOIN membership_contracts ON membership_contracts.id = membership_users.membership_contract_id
          INNER JOIN membership_contract_terms ON membership_contract_terms.membership_contract_id = membership_contracts.id
        SQL
        .where(
          'membership_users.status = ? AND membership_contract_terms.status = ? AND membership_contract_terms.membership_plan_id IN (?)',
          'active',
          'current',
          @plan_ids,
        )
        .distinct
    end

    # Filter users with plan subscription duration
    sig { params(relation: T.untyped).returns(T.untyped) }
    def apply_duration(relation)
      return relation.none if @duration_value.nil? || @duration_unit.nil?

      threshold_date = calculate_threshold_date(@duration_value, @duration_unit)

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

    # Calculate threshold date for duration check
    sig { params(value: Integer, unit: String).returns(Time) }
    def calculate_threshold_date(value, unit)
      case unit
      when 'days'
        value.days.ago
      when 'months'
        value.months.ago
      when 'years'
        value.years.ago
      else
        raise ArgumentError, "Invalid duration_unit: #{unit}"
      end
    end
  end
end
