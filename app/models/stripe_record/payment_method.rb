# typed: strict

# ==============================================================================
# app/models/stripe_record/payment_method.rb
# ==============================================================================
class StripeRecord
  class PaymentMethod < ApplicationRecord
    extend T::Sig
    include Multitenancy
    include StripeConnectable

    self.inheritance_column = :_type_disabled

    belongs_to :user
    belongs_to :setup_intent, optional: true, class_name: 'StripeRecord::SetupIntent'

    scope :valid, -> { where(detached_at: nil).order(created_at: :desc) }

    validates :remote_id, presence: true, uniqueness: true

    sig { returns(T.nilable(String)) }
    def brand
      self.card&.dig('brand')
    end

    sig { returns(T.nilable(String)) }
    def last4
      self.card&.dig('last4')
    end

    sig { returns(T.nilable(Integer)) }
    def exp_month
      self.card&.dig('exp_month')
    end

    sig { returns(T.nilable(Integer)) }
    def exp_year
      self.card&.dig('exp_year')
    end

    sig { returns(T.nilable(String)) }
    def name
      self.billing_details&.dig('name')
    end
  end
end
