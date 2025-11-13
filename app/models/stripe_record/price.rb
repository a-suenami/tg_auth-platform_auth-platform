# typed: strict

# ==============================================================================
# app/models/stripe_record/price.rb
# ==============================================================================
class StripeRecord
  class Price < ApplicationRecord
    extend T::Sig
    include Multitenancy

    after_initialize :set_interval_unit

    belongs_to :product, class_name: 'StripeRecord::Product'
    has_many :plan_payment_methods, class_name: 'Membership::PlanPaymentMethod'
    has_many :subscription_items, class_name: 'StripeRecord::SubscriptionItem'

    attribute :interval_unit

    class IntervalEnum < T::Enum
      enums do
        Day = new('day')
        Week = new('week')
        Year = new('year')
        Month = new('month')
      end
    end

    enumerize :interval, enum_class: IntervalEnum
    enumerize :interval_unit, enum_class: IntervalEnum

    sig { returns(String) }
    def deleted_text
      self.class.human_attribute_name("deleted.#{self.deleted}")
    end

    private

    sig { void }
    def set_interval_unit
      self.interval_unit = self.interval&.value
    end
  end
end
