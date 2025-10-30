# typed: strict

class Membership::ContractTerm < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :user, class_name: '::User'
  belongs_to :membership_contract, class_name: 'Membership::Contract'
  belongs_to :membership_plan, class_name: 'Membership::Plan'

  enum status: {
    current: 'current',
    upcoming: 'upcoming',
    closed: 'closed',
  }

  enum payment_type: {
    credit_card: 'credit_card',
  }
end
