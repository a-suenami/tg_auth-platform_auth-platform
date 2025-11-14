# typed: strict

class UserAutoTaggingRule < ApplicationRecord
  extend T::Sig
  include Multitenancy

  CONDITION_TYPES = T.let(
    %w[membership plan prefecture gender age account_link].freeze,
    T::Array[String],
  )

  belongs_to :tenant
  belongs_to :rule_block, class_name: 'UserAutoTaggingRuleBlock'

  validates :condition_type, presence: true
  validates :condition_type, inclusion: { in: CONDITION_TYPES }
  validates :config, presence: true
  validates :position, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :config_matches_condition_type

  scope :ordered, -> { order(position: :asc) }

  private

  sig { void }
  def config_matches_condition_type
    return if config.blank? || condition_type.blank?

    case condition_type
    when 'membership', 'plan'
      validate_subscription_config
    when 'prefecture', 'gender'
      validate_values_array
    when 'age'
      validate_age_range
    when 'account_link'
      validate_single_value
    end
  end

  sig { void }
  def validate_subscription_config
    subscription_type = config['subscription_type']
    values = config['values']

    unless %w[current duration].include?(subscription_type)
      errors.add(:config, 'subscription_type must be "current" or "duration"')
    end

    unless values.is_a?(Array) && values.any?
      errors.add(:config, 'values must be a non-empty array')
    end

    if subscription_type == 'duration'
      duration_value = config['duration_value']
      duration_unit = config['duration_unit']

      unless duration_value.is_a?(Integer) && duration_value.positive?
        errors.add(:config, 'duration_value must be a positive integer')
      end

      unless %w[days months].include?(duration_unit)
        errors.add(:config, 'duration_unit must be "days" or "months"')
      end
    end
  end

  sig { void }
  def validate_values_array
    values = config['values']

    unless values.is_a?(Array) && values.any?
      errors.add(:config, 'values must be a non-empty array')
    end

    if (condition_type == 'gender') && !values.all? { |v| %w[male female].include?(v) }
      errors.add(:config, 'gender values must be "male" or "female"')
    end
  end

  sig { void }
  def validate_age_range
    min_age = config['min']
    max_age = config['max']

    if min_age.present? && (!min_age.is_a?(Integer) || min_age.negative?)
      errors.add(:config, 'min must be a non-negative integer')
    end

    if max_age.present? && (!max_age.is_a?(Integer) || max_age.negative?)
      errors.add(:config, 'max must be a non-negative integer')
    end

    if min_age.present? && max_age.present? && min_age >= max_age
      errors.add(:config, 'max must be greater than min')
    end

    if min_age.blank? && max_age.blank?
      errors.add(:config, 'at least one of min or max must be present')
    end
  end

  sig { void }
  def validate_single_value
    value = config['value']

    unless value.present? && value.is_a?(String)
      errors.add(:config, 'value must be a non-empty string')
    end

    unless value == 'LINE'
      errors.add(:config, 'value must be "LINE"')
    end
  end
end
