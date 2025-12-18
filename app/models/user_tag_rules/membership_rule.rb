# typed: strict
# frozen_string_literal: true

module UserTagRules
  # Rule to check current membership subscription
  #
  # Config format:
  #   {
  #     "subscription_type": "current",
  #     "values": ["uuid-1", "uuid-2"]  # Membership IDs
  #   }
  #
  # Triggers: [:membership_joined, :membership_left]
  #
  class MembershipRule < AbstractRule
    extend T::Sig

    sig { params(membership_ids: T::Array[String]).void }
    def initialize(membership_ids:)
      @membership_ids = T.let(membership_ids, T::Array[String])
    end

    # Build rule from config hash
    #
    # @param config [Hash] Configuration hash
    # @return [MembershipRule] Rule instance
    sig { params(config: T::Hash[String, T.untyped]).returns(MembershipRule) }
    def self.from_config(config)
      new(membership_ids: config['values'])
    end

    # Events that trigger this rule
    #
    # @return [Array<Symbol>] Event names
    sig { override.returns(T::Array[Symbol]) }
    def events
      [:membership_joined, :membership_left]
    end

    # Filter users matching membership criteria
    #
    # @param relation [ActiveRecord::Relation] Base user relation
    # @return [ActiveRecord::Relation] Filtered relation
    sig { override.params(relation: T.untyped).returns(T.untyped) }
    def apply(relation)
      relation
        .joins('INNER JOIN membership_users ON membership_users.user_id = users.id AND membership_users.tenant_id = users.tenant_id')
        .where('membership_users.status = ? AND membership_users.membership_id IN (?)', 'active', @membership_ids)
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

      errors
    end
  end
end
