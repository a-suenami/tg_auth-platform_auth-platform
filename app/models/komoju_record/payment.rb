# typed: strict
# frozen_string_literal: true

class KomojuRecord::Payment < ApplicationRecord
  extend T::Sig
  include Multitenancy

  # Associations
  belongs_to :user

  # Validations
  validates :remote_id, presence: true, uniqueness: { scope: :tenant_id }
  validates :status, presence: true
  validates :amount, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # Status enum values
  STATUSES = T.let(%w[authorized captured expired cancelled].freeze, T::Array[String])
  validates :status, inclusion: { in: STATUSES }
end
