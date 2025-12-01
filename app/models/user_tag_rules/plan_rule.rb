# typed: strict
# frozen_string_literal: true

module UserTagRules
  # Rule to check current plan subscription
  #
  # Config format:
  #   {
  #     "subscription_type": "current",
  #     "values": ["uuid-1", "uuid-2"]  # Plan IDs
  #   }
  #
  # Triggers: [:plan_joined, :plan_left]
  #
  class PlanRule < AbstractRule
    extend T::Sig

    sig { params(plan_ids: T::Array[String]).void }
    def initialize(plan_ids:)
      @plan_ids = T.let(plan_ids, T::Array[String])
    end

    # Build rule from config hash
    #
    # @param config [Hash] Configuration hash
    # @return [PlanRule] Rule instance
    sig { params(config: T::Hash[String, T.untyped]).returns(PlanRule) }
    def self.from_config(config)
      new(plan_ids: config['values'])
    end

    # Events that trigger this rule
    #
    # @return [Array<Symbol>] Event names
    sig { override.returns(T::Array[Symbol]) }
    def events
      [:plan_joined, :plan_left]
    end

    # Filter users matching plan criteria
    #
    # @param relation [ActiveRecord::Relation] Base user relation
    # @return [ActiveRecord::Relation] Filtered relation
    sig { override.params(relation: T.untyped).returns(T.untyped) }
    def apply(relation)
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

      errors
    end
  end
end
