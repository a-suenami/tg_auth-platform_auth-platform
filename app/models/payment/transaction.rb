# typed: strict
# frozen_string_literal: true

module Payment
  class Transaction < ApplicationRecord
    extend T::Sig
    include Multitenancy

    self.table_name = 'payment_transactions'

    belongs_to :tenant
    belongs_to :user, class_name: '::User'
    belongs_to :membership_contract, class_name: 'Membership::Contract'
    belongs_to :chargeable, polymorphic: true, optional: true

    validates :payment_type, presence: true
    validates :status, presence: true

    validates :paid_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

    enum payment_type: {
      credit_card: 'credit_card',
      convenience: 'convenience',
      campaign_code: 'campaign_code',
      external_linkage: 'external_linkage',
    }

    enum payment_provider: {
      stripe: 'stripe',
      komoju: 'komoju',
    }



    enum status: {
      pending: 'pending',
      active: 'active',
      expired: 'expired',
      canceled: 'canceled',
    }

    scope :active, -> { where(status: :active) }
    scope :recurrent, -> { where(recurrence: true) }
    scope :non_recurrent, -> { where(recurrence: false) }

  end
end
