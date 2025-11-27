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

    # TODO: MR 2 - Execution methods
    # - events(): [:address_changed]
    # - apply(relation): Filter users by prefecture

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

    # TODO: MR 2 - Build rule from config
  end
end
