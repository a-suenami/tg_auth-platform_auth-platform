# typed: strict

class UserAutoTagging < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :created_by, class_name: 'Admin'
  belongs_to :updated_by, class_name: 'Admin', optional: true

  has_one :schedule, class_name: 'AutoTaggingSchedule', dependent: :destroy
  has_many :rule_blocks, class_name: 'UserAutoTagging::RuleBlock', dependent: :destroy

  accepts_nested_attributes_for :schedule, allow_destroy: true
  accepts_nested_attributes_for :rule_blocks, allow_destroy: true

  validates :name, presence: true
  validates :name, uniqueness: { scope: :tenant_id }
  validates :enabled, inclusion: { in: [true, false] }
  validates :shareable, inclusion: { in: [true, false] }

  scope :enabled, -> { where(enabled: true) }
  scope :ordered, -> { order(created_at: :desc) }
  scope :search_by_name, lambda { |term|
    return all if term.blank?

    where(arel_table[:name].lower.matches("%#{sanitize_sql_like(term.downcase)}%"))
  }

  sig { returns(T.nilable(String)) }
  def created_by_name
    created_by&.name
  end

  sig { returns(T.nilable(String)) }
  def updated_by_name
    updated_by&.name
  end
end
