# typed: strict

# ==============================================================================
# app/models/stripe_record/invoice.rb
# ==============================================================================
class StripeRecord
  class Invoice < ApplicationRecord
    extend T::Sig
    include Multitenancy

    belongs_to :user
    # subscription or charge
    belongs_to :payment_source, polymorphic: true, optional: true
    has_many :payment_intents, class_name: 'StripeRecord::PaymentIntent'

    validates :remote_id, presence: true, uniqueness: true

    enumerize :status, in: %w[draft open paid uncollectible void], default: 'draft'
  end
end
