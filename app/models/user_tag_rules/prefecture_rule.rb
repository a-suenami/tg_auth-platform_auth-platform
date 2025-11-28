# typed: strict
# frozen_string_literal: true

module UserTagRules
  # Rule to check if user lives in specified prefectures
  #
  # MR 1 Scope: Config validation only
  #
  # Config format:
  #   {
  #     "values": ["13", "27"]
  #   }
  #
  class PrefectureRule < AbstractRule
    extend T::Sig

    sig { params(prefecture_codes: T::Array[Integer]).void }
    def initialize(prefecture_codes:)
      @prefecture_codes = T.let(prefecture_codes, T::Array[Integer])
    end

    # MR 2.1: Execution methods

    # Build rule from config hash
    #
    # @param config [Hash] Configuration hash
    # @return [PrefectureRule] Rule instance
    sig { params(config: T::Hash[String, T.untyped]).returns(PrefectureRule) }
    def self.from_config(config)
      new(
        prefecture_codes: config['values'].map(&:to_i),
      )
    end

    # Events that trigger this rule
    #
    # @return [Array<Symbol>] Event names
    sig { override.returns(T::Array[Symbol]) }
    def events
      [:address_changed]
    end

    # Filter users matching prefecture criteria
    #
    # @param relation [ActiveRecord::Relation] Base user relation
    # @return [ActiveRecord::Relation] Filtered relation
    sig { override.params(relation: T.untyped).returns(T.untyped) }
    def apply(relation)
      relation
        .joins('INNER JOIN contact_addresses ON contact_addresses.user_id = users.id AND contact_addresses.tenant_id = users.tenant_id')
        .where(contact_addresses: { prefecture_code: @prefecture_codes })
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

      if values.is_a?(Array) && values.any? { |v| v.to_i.zero? && v != '0' }
        errors << I18n.t('user_tag_rules.errors.prefecture_codes_invalid')
      end

      errors
    end
  end
end
