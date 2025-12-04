# typed: strict

class DeliveryActivity < ApplicationRecord
  extend T::Sig
  include Multitenancy

  # Action constants
  ACTIONS = %w[created updated published cancelled paused resumed sent].freeze

  belongs_to :tenant
  belongs_to :delivery
  belongs_to :admin, optional: true

  validates :action, presence: true, inclusion: { in: ACTIONS }

  scope :ordered, -> { order(created_at: :desc) }
  scope :recent, ->(limit = 20) { order(created_at: :desc).limit(limit) }

  sig { params(delivery: Delivery, admin: T.nilable(Admin), action: String, metadata: T::Hash[String, T.untyped], note: T.nilable(String)).returns(DeliveryActivity) }
  def self.record!(delivery:, admin:, action:, metadata: {}, note: nil)
    create!(
      tenant: delivery.tenant,
      delivery: delivery,
      admin: admin,
      action: action,
      metadata: metadata,
      note: note,
    )
  end
end
