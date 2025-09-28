# typed: false

class StripeRecord::TrialHistory < ApplicationRecord
  include Multitenancy
  belongs_to :user, class_name: 'User'
  belongs_to :membership
  belongs_to :membership_plan, class_name: 'Memberships::Plan', inverse_of: :stripe_trial_histories
  belongs_to :stripe_record_subscription, optional: true, class_name: 'StripeRecord::Subscription'
end
