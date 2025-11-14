# typed: strict

class UserTag < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :created_by, class_name: 'Admin', optional: true
  belongs_to :updated_by, class_name: 'Admin', optional: true

  validates :name, presence: true
  validates :name, uniqueness: { scope: :tenant_id, case_sensitive: false }
  validates :name, length: { maximum: 255 }
  validates :description, length: { maximum: 1000 }, allow_nil: true

  scope :ordered, -> { order(created_at: :desc) }
end
