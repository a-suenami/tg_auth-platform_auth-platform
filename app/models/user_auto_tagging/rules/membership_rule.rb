# typed: strict
# frozen_string_literal: true

# Rule to check current membership subscription
#
# Config format:
#   {
#     "values": ["uuid-1", "uuid-2"]  # Membership IDs
#   }
#
# Triggers: [:membership_joined, :membership_left]
#
class UserAutoTagging::Rules::MembershipRule < UserAutoTagging::Rules::AbstractRule
  extend T::Sig

  sig { params(membership_ids: T::Array[String]).void }
  def initialize(membership_ids:)
    @membership_ids = T.let(membership_ids, T::Array[String])
  end

  # TODO: Execution methods
  # - events(): [:membership_joined, :membership_left]
  # - apply(relation): Filter users with current membership in @membership_ids

  # Validate config format
  #
  # @param config [Hash] Configuration hash
  # @return [Array<String>] Array of error messages (empty if valid)
  sig { params(config: T::Hash[String, T.untyped]).returns(T::Array[String]) }
  def self.validate_config(config)
    errors = []

    values = config['values']
    unless values.is_a?(Array) && values.any?
      errors << I18n.t('auto_tagging.rules.errors.values_empty')
    end

    if values.is_a?(Array) && !values.all? { |v| v.is_a?(String) && v.present? }
      errors << I18n.t('auto_tagging.rules.errors.membership_ids_invalid')
    end

    errors
  end
end
