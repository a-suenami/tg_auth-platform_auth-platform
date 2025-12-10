# typed: strict
# frozen_string_literal: true

module UserTagRules
  # Rule to check if user has linked external account
  #
  # Config format:
  #   {
  #     "value": "LINE"
  #   }
  #
  class AccountLinkRule < AbstractRule
    extend T::Sig

    sig { params(provider: String).void }
    def initialize(provider:)
      @provider = T.let(provider, String)
    end

    # MR 2.1: Execution methods

    # Build rule from config hash
    #
    # @param config [Hash] Configuration hash
    # @return [AccountLinkRule] Rule instance
    sig { params(config: T::Hash[String, T.untyped]).returns(AccountLinkRule) }
    def self.from_config(config)
      new(
        provider: config['value'],
      )
    end

    # Events that trigger this rule
    #
    # @return [Array<Symbol>] Event names
    sig { override.returns(T::Array[Symbol]) }
    def events
      [:account_linked, :account_unlinked]
    end

    # Filter users with linked external accounts
    #
    # @param relation [ActiveRecord::Relation] Base user relation
    # @return [ActiveRecord::Relation] Filtered relation
    sig { override.params(relation: T.untyped).returns(T.untyped) }
    def apply(relation)
      relation
        .joins(<<~SQL.squish)
          INNER JOIN users__linked_applications ON users__linked_applications.user_id = users.id AND users__linked_applications.tenant_id = users.tenant_id
          INNER JOIN oauth_applications ON oauth_applications.id = users__linked_applications.oauth_application_id
        SQL
        .where(oauth_applications: { name: @provider })
        .distinct
    end

    # Validate config format
    sig { params(config: T::Hash[String, T.untyped]).returns(T::Array[String]) }
    def self.validate_config(config)
      errors = []

      value = config['value']
      unless value.present? && value.is_a?(String)
        errors << I18n.t('user_tag_rules.errors.account_link_value_empty')
      end

      unless value == 'LINE'
        errors << I18n.t('user_tag_rules.errors.account_link_value_invalid')
      end

      errors
    end
  end
end
