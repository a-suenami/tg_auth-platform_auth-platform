# typed: strict

class MailTemplate::Version < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :template
  belongs_to :published_by, class_name: 'Admin', optional: true

  validates :version, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :version, uniqueness: { scope: :template_id }
  validates :title, presence: true
  validates :body, presence: true
  validates :public_started_at, presence: true

  scope :ordered, -> { order(version: :desc) }
  scope :published, -> { where('public_started_at <= ?', Time.current) }
end
