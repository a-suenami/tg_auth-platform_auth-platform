# typed: strict
# frozen_string_literal: true

module UserTagRules
  # Rule to check membership subscription duration
  #
  # Config format:
  #   {
  #     "subscription_type": "duration",
  #     "values": ["uuid-1", "uuid-2"],  # Membership IDs
  #     "duration_value": 3,
  #     "duration_unit": "months"
  #   }
  #
  # Triggers: [:membership_joined, :membership_left, :new_day_arrived]
  #
  class MembershipDurationRule < AbstractRule
    extend T::Sig

    sig do
      params(
        membership_ids: T::Array[String],
        duration_value: Integer,
        duration_unit: String,
      ).void
    end
    def initialize(membership_ids:, duration_value:, duration_unit:)
      @membership_ids = T.let(membership_ids, T::Array[String])
      @duration_value = T.let(duration_value, Integer)
      @duration_unit = T.let(duration_unit, String)
    end

    # Build rule from config hash
    #
    # @param config [Hash] Configuration hash
    # @return [MembershipDurationRule] Rule instance
    sig { params(config: T::Hash[String, T.untyped]).returns(MembershipDurationRule) }
    def self.from_config(config)
      new(
        membership_ids: config['values'],
        duration_value: config['duration_value'].to_i,
        duration_unit: config['duration_unit'],
      )
    end

    # Events that trigger this rule
    #
    # @return [Array<Symbol>] Event names
    sig { override.returns(T::Array[Symbol]) }
    def events
      [:membership_joined, :membership_left, :new_day_arrived]
    end

    # Filter users matching membership duration criteria
    #
    # @param relation [ActiveRecord::Relation] Base user relation
    # @return [ActiveRecord::Relation] Filtered relation
    sig { override.params(relation: T.untyped).returns(T.untyped) }
    def apply(relation)
      threshold_date = calculate_threshold_date

      relation
        .joins('INNER JOIN membership_users ON membership_users.user_id = users.id AND membership_users.tenant_id = users.tenant_id')
        .where('membership_users.membership_id IN (?) AND membership_users.created_at <= ?', @membership_ids, threshold_date)
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

      if values.is_a?(Array) && !values.all? { |v| v.is_a?(String) && v.present? }
        errors << I18n.t('user_tag_rules.errors.membership_ids_invalid')
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
