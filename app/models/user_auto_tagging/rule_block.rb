# typed: strict

class UserAutoTagging::RuleBlock < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'user_auto_tagging_rule_blocks'

  belongs_to :tenant
  belongs_to :user_auto_tagging

  has_many :rules, class_name: 'UserAutoTagging::Rule', dependent: :destroy, inverse_of: :rule_block

  accepts_nested_attributes_for :rules, allow_destroy: true

  validates :position, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(position: :asc) }
end
