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

  VALID_PROVIDERS = T.let(%w[LINE].freeze, T::Array[String])

  sig { returns(T.untyped) }
  attr_accessor :value

  validates :value, presence: { message: ->(_object, _data) { I18n.t('auto_tagging.rules.errors.account_link_value_empty') } }
  validates :value, inclusion: {
    in: VALID_PROVIDERS,
    message: ->(_object, _data) { I18n.t('auto_tagging.rules.errors.account_link_value_invalid') },
  }, if: -> { value.present? }

  sig { params(config: T::Hash[String, T.untyped]).void }
  def initialize(config = {})
    super()
    @value = T.let(config['value'], T.untyped)
  end

  # TODO: Execution methods
  # - events(): [:account_linked, :account_unlinked]
  # - apply(relation): Filter users with linked accounts
end
