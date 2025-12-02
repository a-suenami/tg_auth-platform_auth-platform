# typed: strict
# frozen_string_literal: true

# Rule to check if user has linked external account
#
# Config format:
#   {
#     "value": "LINE"
#   }
#
class UserAutoTagging::Rules::AccountLinkRule < UserAutoTagging::Rules::AbstractRule
  extend T::Sig

  sig { params(provider: String).void }
  def initialize(provider:)
    @provider = T.let(provider, String)
  end

  # TODO: Execution methods
  # - events(): [:account_linked, :account_unlinked]
  # - apply(relation): Filter users with linked accounts

  # Validate config format
  sig { params(config: T::Hash[String, T.untyped]).returns(T::Array[String]) }
  def self.validate_config(config)
    errors = []

    value = config['value']
    unless value.present? && value.is_a?(String)
      errors << I18n.t('auto_tagging.rules.errors.account_link_value_empty')
    end

    unless value == 'LINE'
      errors << I18n.t('auto_tagging.rules.errors.account_link_value_invalid')
    end

    errors
  end

  # TODO: Build rule from config
end
