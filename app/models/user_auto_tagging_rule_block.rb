# typed: strict

class UserAutoTaggingRuleBlock < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :user_auto_tagging

  has_many :rules, class_name: 'UserAutoTaggingRule', foreign_key: :rule_block_id, dependent: :destroy, inverse_of: :rule_block

  accepts_nested_attributes_for :rules, allow_destroy: true

  validates :position, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(position: :asc) }
end
