# typed: strict

# ==============================================================================
# app/models/stripe_record/invoice.rb
# ==============================================================================
class StripeRecord
  class Invoice < ApplicationRecord
    extend T::Sig
    include Multitenancy

    belongs_to :user
    belongs_to :chargeable, polymorphic: true, optional: true

    validates :remote_id, presence: true, uniqueness: true

    enumerize :status, in: %w[draft open paid uncollectible void], default: 'draft'
  end
end
