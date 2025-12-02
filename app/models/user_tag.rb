# typed: strict

class UserTag < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :created_by, class_name: 'Admin'
  belongs_to :updated_by, class_name: 'Admin', optional: true

  has_many :tag_assignments, class_name: 'UserTagAssignment', dependent: :destroy
  has_many :users, through: :tag_assignments
  has_many :auto_tagging_tags, class_name: 'UserAutoTaggingTag', dependent: :destroy
  has_many :user_auto_taggings, through: :auto_tagging_tags

  validates :name, presence: true
  validates :name, uniqueness: { scope: :tenant_id, case_sensitive: false }
  validates :name, length: { maximum: 255 }
  validates :description, length: { maximum: 1000 }, allow_nil: true

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
