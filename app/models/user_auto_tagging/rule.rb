# typed: strict

class UserAutoTagging::Rule < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'user_auto_tagging_rules'

  CONDITION_TYPES = T.let(
    %w[membership plan prefecture gender age account_link].freeze,
    T::Array[String],
  )

  belongs_to :tenant
  belongs_to :rule_block, class_name: 'UserAutoTagging::RuleBlock'

  validates :condition_type, presence: true
  validates :condition_type, inclusion: { in: CONDITION_TYPES }
  validates :config, presence: true
  validates :position, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :config_matches_condition_type

  scope :ordered, -> { order(position: :asc) }

  # TODO: Rule execution
  # def to_rule
  #   Build rule engine instance for execution
  #   UserTagRules::RuleFactory.build(condition_type, config)
  # end

  private

  sig { void }
  def config_matches_condition_type
    return if config.blank? || condition_type.blank?

    validation_errors = UserTagRules::RuleFactory.validate(condition_type, config)
    validation_errors.each do |error_message|
      errors.add(:config, error_message)
    end
  end
end
