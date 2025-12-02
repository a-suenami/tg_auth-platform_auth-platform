# typed: strict
# frozen_string_literal: true

# Rule to check user's gender
#
# Config format:
#   {
#     "values": ["male", "female"]
#   }
#
class UserAutoTagging::Rules::GenderRule < UserAutoTagging::Rules::AbstractRule
  extend T::Sig

  sig { params(genders: T::Array[String]).void }
  def initialize(genders:)
    @genders = T.let(genders, T::Array[String])
  end

  # TODO: Execution methods
  # - events(): [:profile_updated]
  # - apply(relation): Filter users by gender

  # Validate config format
  sig { params(config: T::Hash[String, T.untyped]).returns(T::Array[String]) }
  def self.validate_config(config)
    errors = []

    values = config['values']
    unless values.is_a?(Array) && values.any?
      errors << I18n.t('auto_tagging.rules.errors.values_empty')
    end

    if values.is_a?(Array) && !values.all? { |v| %w[male female].include?(v) }
      errors << I18n.t('auto_tagging.rules.errors.gender_values_invalid')
    end

    errors
  end

  # TODO: Build rule from config
end
